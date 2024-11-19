import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  
  File? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (!kIsWeb) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }
  }

  Future<File?> compressImage(File file) async {
    if (kIsWeb) return null;
    
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 500,
        minHeight: 500,
        rotate: 0,
      );
      
      if (result != null) {
        final originalSize = await file.length();
        final compressedSize = await result.length();
        
        print('Original size: ${(originalSize / 1024).round()}KB');
        print('Compressed size: ${(compressedSize / 1024).round()}KB');
        
        return File(result.path);
      }
      return null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (!kIsWeb) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission denied');
          }
        }
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      if (image == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (kIsWeb) {
        // Handle web image
        _webImage = await image.readAsBytes();
        setState(() {
          _imageFile = null;
          _isLoading = false;
        });
      } else {
        // Handle mobile image
        File originalFile = File(image.path);
        File? compressedFile = await compressImage(originalFile);
        
        setState(() {
          _imageFile = compressedFile ?? originalFile;
          _webImage = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      String errorMessage = 'Error selecting image';
      
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please grant storage access.';
      }
      
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
        )
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validatePassword(String password) {
    final RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<bool> _isUsernameAvailable(String username) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return result.docs.isEmpty;
  }

  Future<String?> _uploadProfilePicture(String userId) async {
    if (_imageFile == null && _webImage == null) return null;
    
    try {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');
      
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_at': DateTime.now().toIso8601String(),
          'user_id': userId,
        }
      );
      
      // Upload with retry mechanism
      int retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries) {
        try {
          if (kIsWeb && _webImage != null) {
            await storageRef.putData(_webImage!, metadata);
          } else if (_imageFile != null) {
            await storageRef.putFile(_imageFile!, metadata);
          }
          return await storageRef.getDownloadURL();
        } catch (e) {
          retryCount++;
          if (retryCount == maxRetries) rethrow;
          await Future.delayed(Duration(seconds: retryCount));
          continue;
        }
      }
      
      return null;
    } catch (e) {
      print('Error uploading profile picture: $e');
      String errorMessage = 'Error uploading profile picture';
      
      if (e is FirebaseException) {
        switch (e.code) {
          case 'storage/unauthorized':
            errorMessage = 'Not authorized to upload files';
            break;
          case 'storage/canceled':
            errorMessage = 'Upload was cancelled';
            break;
          case 'storage/quota-exceeded':
            errorMessage = 'Storage quota exceeded';
            break;
          default:
            errorMessage = 'Upload failed: ${e.message}';
        }
      }
      
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(errorMessage))
      );
      return null;
    }
  }

  Future<void> _handleSignup() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate inputs
      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty ||
          usernameController.text.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      if (passwordController.text != confirmPasswordController.text) {
        throw Exception('Passwords do not match');
      }

      if (!_validatePassword(passwordController.text)) {
        throw Exception('Password must be at least 8 characters long and contain uppercase, lowercase, and numbers');
      }

      // Check username availability
      bool isUsernameAvailable = await _isUsernameAvailable(usernameController.text);
      if (!isUsernameAvailable) {
        throw Exception('Username is already taken');
      }

      // Create user account
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      // Upload profile picture if selected
      String? profilePictureUrl;
      if (_imageFile != null || _webImage != null) {
        profilePictureUrl = await _uploadProfilePicture(userCredential.user!.uid);
      }

      // Create user document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'username': usernameController.text,
            'email': emailController.text.trim(),
            'profilePicture': profilePictureUrl,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Show success message
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Account created successfully!'))
      );

      // Navigate to home page or login page
      Navigator.pop(context);
    } catch (e) {
      print('Error during signup: $e');
      String errorMessage = 'Error creating account';
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Email is already registered';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak';
            break;
          default:
            errorMessage = e.message ?? 'Error creating account';
        }
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(errorMessage))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  ImageProvider? _getImageProvider() {
    if (kIsWeb && _webImage != null) {
      return MemoryImage(_webImage!);
    } else if (_imageFile != null) {
      return FileImage(_imageFile!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      child: Text(
                        "Create an account, It's free",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700]
                        ),
                      )
                    ),
                  ],
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 1100),
                  child: GestureDetector(
                    onTap: _isLoading ? null : _pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _getImageProvider(),
                          child: _imageFile == null && _webImage == null
                              ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey[800])
                              : null,
                        ),
                        if (_isLoading)
                          const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      child: makeInput(label: "Username", controller: usernameController)
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1300),
                      child: makeInput(label: "Email", controller: emailController)
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1400),
                      child: makeInput(label: "Password", obscureText: true, controller: passwordController)
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: makeInput(label: "Confirm Password", obscureText: true, controller: confirmPasswordController)
                    ),
                  ],
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 1600),
                  child: Container(
                    padding: const EdgeInsets.only(top: 3, left: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black),
                    ),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: _isLoading ? null : _handleSignup,
                      color: Colors.greenAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign up",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18
                              ),
                            ),
                    ),
                  )
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 1700),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget makeInput({label, obscureText = false, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400)
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400)
            ),
          ),
        ),
        SizedBox(height: 30,),
      ],
    );
  }
}