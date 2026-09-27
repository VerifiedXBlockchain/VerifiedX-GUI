import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/token/models/token_vote_topic.dart';

TokenVoteTopic _topic(List<WebTokenVoteTopicVoteDataItem>? votes) => TokenVoteTopic(
      smartContractUid: 'sc-1',
      topicUid: 'topic-1',
      topicName: 'Topic',
      topicDescription: 'Description',
      minimumVoteRequirement: 1,
      tokenHolderCount: 0,
      topicCreateDate: 0,
      votingEndDate: 0,
      blockHeight: 0,
      voteYes: 0,
      voteNo: 0,
      totalVotes: 0,
      percentVotesYes: 0,
      percentVotesNo: 0,
      percentInFavor: 0,
      percentAgainst: 0,
      webVoteList: votes,
    );

void main() {
  group('TokenVoteTopic.webVoteFor', () {
    const voter = 'xMfCxAbCdEfGhIjKlMnOpQrStUvWxYz1234';
    final vote = WebTokenVoteTopicVoteDataItem(address: voter, value: true, createdAt: DateTime(2026, 9, 1));

    test('finds the vote the address already cast, so a reload keeps "You have voted"', () {
      expect(_topic([vote]).webVoteFor(voter), vote);
    });

    test('matches the address regardless of case and whitespace', () {
      expect(_topic([vote]).webVoteFor(' ${voter.toLowerCase()} '), vote);
    });

    test('is null when the address has not voted', () {
      expect(_topic([vote]).webVoteFor('xOtherAddressAbCdEfGhIjKlMnOpQrStU'), isNull);
    });

    test('is null when the topic carries no web vote list', () {
      expect(_topic(null).webVoteFor(voter), isNull);
    });
  });
}
