# Metric tree

North Star: **net revenue per session** (revenue per session after refunds). Gross value in Feb 2015: $5.43.

```
Net revenue per session
├── Conversion rate (session to order)              8.7% in Feb 2015
│   ├── Landing to products                         55%   (mobile 47%, desktop 59%)
│   ├── Products to product page                    80%
│   ├── Product page to cart                        45%
│   └── Cart to order (shipping, billing, thank-you) 34%  (mobile 23%, desktop 37%)
└── Net revenue per order                           AOV $62.48 in Feb 2015
    ├── Cross-sell: share of orders with an add-on  about 35% since Feb 2014
    ├── Product mix and price
    └── Refunds                                     4.3% of items sold (whole period)
```

Funnel rates are averages for April 2012 to February 2015 (module 03).

**Guardrails** (must not get worse when we push the North Star): gross margin (63.5% in Feb 2015), refund rate, page speed (not in the data).

**Outside the tree:** traffic volume by channel. It is a separate lever, and channel cost is not in the data, so it is tracked but not optimised here.

## How I use it

- A change is judged on its own step first (for example, landing to products), then on conversion, then on net revenue per session.
- Every experiment names one primary metric from the tree and at least two guardrails.
