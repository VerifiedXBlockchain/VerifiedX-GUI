import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/core/services/transaction_service.dart';
import 'package:rbx_wallet/features/store/models/listing.dart';
import 'package:rbx_wallet/utils/toast.dart';
import 'package:rbx_wallet/utils/validation.dart';

class CreateListingModel {
  final bool hasAuction;
  final bool hasBuyNow;
  final DateTime? startsAt;
  final DateTime? endsAt;
  const CreateListingModel({
    this.hasAuction = false,
    this.hasBuyNow = false,
    this.startsAt,
    this.endsAt,
  });

  CreateListingModel copyWith({
    bool? hasAuction,
    bool? hasBuyNow,
    DateTime? startsAt,
    DateTime? endsAt,
  }) {
    return CreateListingModel(
      hasAuction: hasAuction ?? this.hasAuction,
      hasBuyNow: hasBuyNow ?? this.hasBuyNow,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
    );
  }
}

class CreateListingProvider extends StateNotifier<CreateListingModel> {
  final Reader read;
  final int storeId;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late final TextEditingController startsAtController = TextEditingController();
  late final TextEditingController endsAtController = TextEditingController();
  late final TextEditingController floorPriceController = TextEditingController();
  late final TextEditingController buyNowPriceController = TextEditingController();

  CreateListingProvider(this.read, this.storeId, [CreateListingModel model = const CreateListingModel()]) : super(model) {
    init();
  }

  init() async {}

  String? nameValidator(String? value) => formValidatorNotEmpty(value, "Name");
  String? descriptionValidator(String? value) => formValidatorNotEmpty(value, "Description");
  String? startsAtValidator(String? value) => formValidatorNotEmpty(value, "Starts At");
  String? endsAtValidator(String? value) => formValidatorNotEmpty(value, "Ends At");

  String? floorPriceValidator(String? value) => formValidatorNumber(value, "Floor Price");
  String? buyNowPriceValidator(String? value) => formValidatorNumber(value, "Buy Now Price");

  void setHasAuction(bool val) {
    state = state.copyWith(hasAuction: val);
  }

  void setHasBuyNow(bool val) {
    state = state.copyWith(hasBuyNow: val);
  }

  void setDate(DateTime date, bool forStartsAt) {
    date = DateUtils.dateOnly(date);

    state = forStartsAt ? state.copyWith(startsAt: date) : state.copyWith(endsAt: date);

    if (forStartsAt) {
      startsAtController.text = DateFormat.yMd().format(date);
    } else {
      endsAtController.text = DateFormat.yMd().format(date);
    }
  }

  Future<String?> submit() async {
    final keypair = read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("No keypair");
      return null;
    }

    if (!formKey.currentState!.validate()) {
      return null;
    }

    if (!state.hasBuyNow && !state.hasAuction) {
      Toast.error("Either Auction or Buy Now is required");
      return null;
    }
    if (state.startsAt == null || state.endsAt == null) {
      Toast.error("Starts at / Ends at are required");
      return null;
    }
    if (state.startsAt!.compareTo(state.endsAt!) > 0) {
      Toast.error("Start Date must be before End Date");
      return null;
    }

    final buyNowPrice = state.hasBuyNow ? double.tryParse(buyNowPriceController.text) : null;
    final floorPrice = state.hasAuction ? double.tryParse(floorPriceController.text) : null;

    final Map<String, dynamic> params = {
      'name': nameController.text,
      'description': descriptionController.text,
      'starts_at': state.startsAt!.toIso8601String(),
      'ends_at': state.endsAt!.toIso8601String(),
      ...buyNowPrice != null ? {'buy_now_price': buyNowPrice} : {},
      ...floorPrice != null ? {'floor_price': floorPrice} : {},
      'store': storeId,
      'email': keypair.email,
      'address': keypair.public,
    };

    final slug = await TransactionService().createListing(params);

    if (slug == null) {
      Toast.error();
      return null;
    }

    return slug;
  }
}

final createListingProvider = StateNotifierProvider.family<CreateListingProvider, CreateListingModel, int>((ref, storeId) {
  return CreateListingProvider(ref.read, storeId);
});