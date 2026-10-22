"""
Two-proportion test for the billing page experiment.

Usage:
    python 02_billing_test_stats.py <ctrl_sessions> <ctrl_orders> <var_sessions> <var_orders>

Control = /billing (old page), variant = /billing-2 (new page).
Inputs come from QUERY 1 in 01_billing_test.sql.
Requires: pip install statsmodels
"""
import sys

from statsmodels.stats.power import NormalIndPower
from statsmodels.stats.proportion import (
    confint_proportions_2indep,
    proportion_effectsize,
    proportions_ztest,
)


def main(n_ctrl, x_ctrl, n_var, x_var):
    p_ctrl, p_var = x_ctrl / n_ctrl, x_var / n_var
    diff = p_var - p_ctrl

    # H0: both pages have the same conversion rate. Two-sided z-test.
    z_stat, p_value = proportions_ztest([x_var, x_ctrl], [n_var, n_ctrl])

    # 95% confidence interval for the difference (variant minus control).
    low, high = confint_proportions_2indep(
        x_var, n_var, x_ctrl, n_ctrl, method="wald", compare="diff"
    )

    # Sample size per group needed to detect a difference this size
    # at 5% significance and 80% power.
    effect = proportion_effectsize(p_var, p_ctrl)
    needed = NormalIndPower().solve_power(
        effect_size=abs(effect), alpha=0.05, power=0.8, ratio=1.0
    )

    print(f"control  (/billing)  : {x_ctrl}/{n_ctrl} = {p_ctrl:.4%}")
    print(f"variant  (/billing-2): {x_var}/{n_var} = {p_var:.4%}")
    print(f"absolute lift        : {diff:+.2%} points")
    print(f"relative lift        : {diff / p_ctrl:+.1%}")
    print(f"95% CI of difference : [{low:+.2%}, {high:+.2%}]")
    print(f"z = {z_stat:.2f}, p-value = {p_value:.4g}")
    print(f"sample needed per group (80% power): {needed:,.0f}")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    a, b, c, d = (int(v) for v in sys.argv[1:])
    main(a, b, c, d)