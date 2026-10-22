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

  group('WebTokenVoteTopic.toNative', () {
    TokenVoteTopic topicWithShares(double yes, double no) => WebTokenVoteTopic(
          smartContractUid: 'sc-1',
          topicUid: 'topic-1',
          topicName: 'Topic',
          topicDescription: 'Description',
          minimumVoteRequirement: 50,
          topicCreateDate: DateTime.utc(2026, 10, 21),
          votingEndDate: DateTime.utc(2026, 11, 20),
          voteData: WebTokenVoteTopicVoteData(votes: const [], voteYes: 1, voteNo: 1, totalVotes: 2, percentYes: yes, percentNo: no),
        ).toNative();

    test("turns Spyglass's fractions into the percentages the screen shows", () {
      final allYes = topicWithShares(1.0, 0.0);
      expect(allYes.percentVotesYes, 100);
      expect(allYes.percentVotesNo, 0);

      final split = topicWithShares(0.5, 0.5);
      expect(split.percentVotesYes, 50);
      expect(split.percentVotesNo, 50);
    });

    test('rounds a share to 2 decimals, as Core does', () {
      expect(topicWithShares(1 / 3, 2 / 3).percentVotesYes, 33.33);
      expect(topicWithShares(1 / 3, 2 / 3).percentAgainst, 66.67);
    });
  });
}
