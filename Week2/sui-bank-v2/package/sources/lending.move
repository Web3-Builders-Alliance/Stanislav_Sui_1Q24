module sui_bank::lending {
  // === Imports ===

  use sui::coin::Coin;
  use sui::tx_context::TxContext;
  use sui::transfer;
  use sui::object::{Self, UID};

  use sui_bank::bank::{Self, Account, OwnerCap};
  use sui_bank::oracle::{Self, Price}; 
  use sui_bank::sui_dollar::{Self, CapWrapper, SUI_DOLLAR}; 

  // === Errors ===

  const EBorrowAmountIsTooHigh: u64 = 0;
  const EWrongLtv: u64 = 1;

  // === Constants ===

  const DEFAULT_LTV: u128 = 40;

  // === Structs ===

  struct LendingParams has key {
    id: UID,
    ltv: u128,
  }

   // === Init ===

  fun init(ctx: &mut TxContext) {
    transfer::share_object(
      LendingParams {
        id: object::new(ctx),
        ltv: DEFAULT_LTV,
      }
    );
  }

  // === Public-Mutative Functions ===

  public fun borrow(account: &mut Account, params: &LendingParams, cap: &mut CapWrapper, price: Price, value: u64, ctx: &mut TxContext): Coin<SUI_DOLLAR> {
    let (latest_result, scaling_factor, _) = oracle::destroy(price);

    let max_borrow_amount = (((((bank::account_balance(account) as u128) * latest_result / scaling_factor) * params.ltv) / 100) as u64);

    let debt_mut = bank::debt_mut(account);

    assert!(max_borrow_amount >= *debt_mut + value, EBorrowAmountIsTooHigh);

    *debt_mut = *debt_mut + value;

    sui_dollar::mint(cap, value, ctx)
  }

  public fun repay(account: &mut Account, cap: &mut CapWrapper, coin_in: Coin<SUI_DOLLAR>) {
    let amount = sui_dollar::burn(cap, coin_in);

    let debt_mut = bank::debt_mut(account);

    *debt_mut = *debt_mut - amount;
  }

  // === Admin Functions ===

  public fun change_ltv(_: &OwnerCap, params: &mut LendingParams, new_ltv: u128) {
    assert!(new_ltv < 100, EWrongLtv);
    params.ltv = new_ltv;
  }
}