module sui_bank::oracle {
  // === Imports ===

  use switchboard::aggregator::{Self, Aggregator};
  use switchboard::math;
  use sui::clock::{Self, Clock};
  use sui::tx_context::TxContext;
  use sui::transfer;
  use sui::object::{Self, UID};
  use sui::math as sui_math;

  use sui_bank::bank::OwnerCap;

  // === Errors ===

  const EPriceIsNegative: u64 = 0;
  const EPriceIsWrong: u64 = 1;
  const ETimestampIsWrong: u64 = 2;
  const EAggregatorIsWrong: u64 = 2;

  // === Constants ===

  const TIME_MARGIN: u64 = 5_000;
  const DEFAULT_AGREGATOR: address = @0x84d2b7e435d6e6a5b137bf6f78f34b2c5515ae61cd8591d5ff6cd121a21aa6b7;

  // === Structs ===

  struct Price {
    latest_result: u128,
    scaling_factor: u128,
    latest_timestamp: u64,
  }

  struct OracleParams has key {
    id: UID,
    aggregator: address,
  }

     // === Init ===

  fun init(ctx: &mut TxContext) {
    transfer::share_object(
      OracleParams {
        id: object::new(ctx),
        aggregator: DEFAULT_AGREGATOR,
      }
    );
  }

  // === Public-Mutative Functions ===

  public fun new(feed: &Aggregator, params: &OracleParams, clock: &Clock): Price {
    assert!(aggregator::aggregator_address(feed) == params.aggregator, EAggregatorIsWrong);
    
    let (latest_result, latest_timestamp) = aggregator::latest_value(feed);

    let (value, scaling_factor, neg) = math::unpack(latest_result);

    assert!(value > 0, EPriceIsWrong);
    assert!(!neg, EPriceIsNegative);

    let current_timestamp = clock::timestamp_ms(clock);
    assert!((latest_timestamp + TIME_MARGIN) > current_timestamp, ETimestampIsWrong);

    Price {
      latest_result: value,
      scaling_factor: (sui_math::pow(10, scaling_factor) as u128),
      latest_timestamp
    }
  }

  public fun destroy(self: Price): (u128, u128, u64) {
    let Price { latest_result, scaling_factor, latest_timestamp } = self;
    (latest_result, scaling_factor, latest_timestamp)
  }

  // === Admin Functions ===

  public fun change_aggregator(_: &OwnerCap, params: &mut OracleParams, new_aggregator: address) {
    params.aggregator = new_aggregator;
  }

  // === Test Functions ===

  #[test_only]
  
  public fun new_for_testing(latest_result: u128, scaling_factor: u128, latest_timestamp: u64): Price {
    Price {
      latest_result,
      scaling_factor,
      latest_timestamp
    }
  }
}