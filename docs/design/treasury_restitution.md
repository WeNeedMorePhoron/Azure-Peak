# Treasury Restitution and NERVE MASTER Port

Branch: `restitution-and-ui` (off main). Standalone fix already on `fine-stuffs` (b16c3dfd07): PAY gated behind fiscal authority, self-fines refused.

## Problem

A fiscal officer can PAY themselves from the Crown's Purse. Fines are the only recovery tool, and they are a levy against subjects: Golden Bull caps them at 50m/day for residents, the Great Writ exempts nobles, and the one-fine-per-name-per-day ledger can be pre-empted by a 1m self-fine. None of that should change. The Crown needs a way to reverse its own disbursement instead.

## Rules

- Restitution reverses a Crown grant made through the PAY action. Salary, church funding, retirement endowments, bounties and trade payouts are not grants and are never reversible.
- Reversible up to the unreversed remainder of the grant, within `RESTITUTION_WINDOW_DAYS` (2) of the grant day. Partial reversal allowed.
- Rank gate. Fiscal rank: Clerk 1, Steward 2, Grand Duke / Regent 3. An officer may reverse any grant they made themselves, and any grant made by a lower rank. Rank is stamped on the grant entry at grant time so a dead or replaced grantor does not block reversal.
- Recovery takes what is in the account. Any shortfall becomes restitution debt on the recipient, collected at dawn after wages land so the wage is garnished naturally.
- No consultation of fine caps, the daily fine ledger, or any decree. Nobles and outlaws are reversed like anyone else.
- Refused while the round-end vote is open, mirroring fines.

## Why not poll-tax arrears for the shortfall

`tick_poll_tax` skips a head entirely when its category rate is 0, and every category defaults to 0. Piping restitution shortfall into `poll_tax_owed` would silently never collect. Restitution debt gets its own small tick.

## Slices

Each slice compiles and is reviewable on its own. Slices 1 to 4 are the restitution package. Slices 5 to 7 are the rest of the HTML port and can trail.

### Slice 0. Cherry-pick the fine fix

Cherry-pick b16c3dfd07 so the branch is complete standalone and the treasury-level self-fine refusal is present before the Bank tab is rewritten.

### Slice 1. Ledger provenance

Files: `code/modules/banking/treasury_entry.dm`, `code/modules/banking/fund_api.dm`, `code/controllers/subsystem/rogue/treasury.dm`, `steward.dm` PAY handler, `StewardTrade/LedgerView.tsx`, `StewardTrade/types.ts`.

- `/datum/treasury_entry` gains `actor_name`, `actor_rank`, `day_created`, `reversed_amount`.
- New entry kind `grant`. `log_fund_entry` never coalesces `grant` entries.
- New proc `SStreasury.crown_grant(amount, mob/target, mob/actor, reason)`: transfers from the Purse, logs a `grant` entry stamped with the actor, calls `record_treasury_payout`, sends the existing MEISTER note and game log. The PAY handler calls this instead of `give_money_account`. All other positive callers of `give_money_account` are untouched.
- Ledger tab renders `grant` rows with "by <actor>" so the provenance is visible before any reversal UI exists.

Review focus: the actor stamp, the no-coalesce rule, and that only the PAY path produces `grant` entries.

### Slice 2. Restitution core

Files: `code/__DEFINES/banking.dm`, new `code/modules/banking/restitution.dm`.

- `RESTITUTION_WINDOW_DAYS` define.
- `fiscal_rank(mob)` helper next to `has_fiscal_authority`.
- `SStreasury.get_reversible_grants(mob/recipient, mob/actor)`: grant entries to that account, inside the window, with remainder > 0, filtered by the rank gate.
- `SStreasury.reverse_grant(mob/actor, datum/treasury_entry/E, amount)`: clamps to remainder, transfers what the account holds back to the Purse as kind `restitution`, bumps `reversed_amount`, records shortfall into `restitution_owed[recipient]`, notifies recipient, logs `RESTITUTION:` game line, records a new `STATS_RESTITUTION_RECOVERED` round stat.

No UI. Tested together with slice 4.

### Slice 3. Restitution debt collection

Files: `treasury.dm` dawn hook in `code/__HELPERS/time.dm`, `steward.dm` Debt tab.

- `SStreasury.tick_restitution_debt()` runs at dawn after `distribute_daily_payments`. Takes min(balance, owed) to the Purse, notifies, clears the key when paid.
- Debt tab lists outstanding restitution debt next to poll arrears and loans.

### Slice 4. Accounts window in tgui, restitution UI

Files: new `code/modules/roguetown/roguemachine/steward/steward_bank_tgui.dm`, new `tgui/packages/tgui/interfaces/NerveMaster.tsx` and `NerveMaster/AccountsView.tsx`, `steward.dm` (delete HTML Bank tab body, link main tab to the new window).

- Separate tgui window from the Market Scroll. The Market Scroll's `ui_state` lets the Alderman act remotely, and accounts must never ride that exception. The new window uses `human_adjacent_state` and every action checks `has_fiscal_authority`.
- Accounts tab: same row data the HTML tab shows (name, job, balance, arrears, debtor, wage status, max fine or exempt reason) plus restitution owed. Actions: Pay, Fine, Suspend/Reinstate wages, and a Grants drawer per account listing reversible grants with amount, day, grantor, remainder, and a Reverse button with an amount input.
- Pay and Fine handlers move here from the HTML `Topic`. The HTML Bank tab is removed in the same slice so there is one code path.
- Payroll by class stays on the HTML Payday tab until slice 5.

### Slice 5. Debts and Payday tabs

Port `clearloandebtor`, `clearpolltax`, `payroll`, `setdailypay`, `removedailypay` into the NerveMaster window as Debts and Payday tabs. Remove the HTML tabs.

### Slice 6. Fiscal and Import tabs

Port the round-stat Fiscal Ledger and the crown-import list. Remove the HTML tabs.

### Slice 7. Retire the HTML panel

`attack_hand` opens NerveMaster directly. `printresidency`, `setpurchasefloor` and `compact` move to an Office section. Delete the `Topic` proc and tab defines.

## Open decisions

- Window length: 2 days proposed.
- Whether a Steward may reverse a Grand Duke's grant: proposed no, rank must be strictly higher or the same person.
- Whether reversal should announce anything beyond the recipient's MEISTER note: proposed no.
