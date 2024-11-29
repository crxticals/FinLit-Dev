class Vocab{
  final String word;
  final String definition;

  Vocab(
    this.word,
    this.definition,
  );
}

List vocab = [
  Vocab('Stream of Cash Flows', 'A series of payments or receipts of income occurring over multiple time periods.'),
  Vocab('Timeline', 'A visual tool showing specific dates to track the timing of each cash flow.'),
  Vocab('Date 0', 'The starting point on a timeline, typically representing the present.'),
  Vocab('Inflows', 'Positive cash flows, or money received.'),
  Vocab('Outflows', 'Negative cash flows, or money paid out.'),
  Vocab('Time Period', ' The time frame interval between dates on a timeline, such as a year, month, or day.'),
  Vocab('Cash Flow Sign Convention', 'A method for differentiating inflows (positive) and outflows (negative) on the timeline.')
];