# BikeStore Sales Analysis (SQL)

A SQL project that answers 23 business questions about a bike retailer (BikeStore) using **SQL Server (T-SQL)**: sales, revenue, customers, products, brands, staff, and inventory across multiple stores.

## Business Questions Covered

| Area | Questions |
|---|---|
| **Products & pricing** | Most expensive bike, least sold bike, discounted price of a product, full details of a product |
| **Sales & revenue** | Total price per order, revenue per store, most sold category, children bicycles sold in the last 8 months of the data |
| **Brands & categories** | Most liked brand, least liked category, categories with the most rejected orders |
| **Customers** | Total customers, customer lookup, purchase history, order status, and shipped date for specific customers |
| **Operations** | Number of stores, states, staff and managers, staff handling a specific order, pending orders, stock of the top brand per store |

## Database Schema

Two schemas, 9 tables:

- **sales:** `customers`, `orders`, `order_items`, `staffs`, `stores`
- **production:** `products`, `categories`, `brands`, `stocks`

Order status codes: `1` Pending, `2` Processing, `3` Rejected, `4` Completed.

## SQL Skills Demonstrated

- Multi-table `JOIN`s (up to 5 tables), including `LEFT JOIN`
- Aggregations with `GROUP BY`, `SUM`, `COUNT`, `COUNT(DISTINCT)`, `MAX`
- Ranking with `TOP ... WITH TIES` and `ORDER BY`
- Common Table Expressions (CTE) and subqueries
- Date logic with `DATEADD`, relative to the latest order date in the data
- Calculated fields (discounted revenue = `list_price * quantity * (1 - discount)`)
- `CASE` expressions to decode order status

## Key Findings

| Metric | Result |
|---|---|
| Customers | **1,445** |
| Stores / States | **3** stores across **3** states |
| Staff / Managers | **10** staff, **4** managers |
| Most expensive bike | **Trek Domane SLR 9 Disc - 2018** (11,999.99) |
| Most sold category | **Cruisers Bicycles** (2,063 units) |
| Least sold category | **Electric Bikes** (315 units) |
| Most liked brand | **Electra** (2,612 units sold) |
| Pending orders | **62** |
| Children Bicycles sold in the last 8 months of the data | **18 units** |

**Revenue per store** (rejected orders excluded)

| Store | Revenue | Share |
|---|---|---|
| Baldwin Bikes | 5,138,474 | ~69% |
| Santa Cruz Bikes | 1,560,539 | ~21% |
| Rowlett Bikes | 781,523 | ~10% |

**Categories with the most rejected orders:** Cruisers Bicycles (31), Mountain Bikes (22), Children Bicycles (13).

### Observations

- **Revenue is concentrated in one store.** Baldwin Bikes generates about 69% of total revenue, roughly 6.6x more than Rowlett Bikes.
- **Cruisers lead in both sales and rejections.** The best-selling category also has the most rejected orders. Since it also has the highest volume, comparing rejection *rates* would be a useful next step.
- **Electra dominates the brand ranking**, while Electric Bikes are the weakest category by units sold.
- **Some products were never sold.** The least-sold query returns several products with zero units sold.
- **Inventory vs. revenue:** Santa Cruz Bikes holds the most stock of the top brand (1,715 Electra units), while Baldwin Bikes generates most of the revenue. This is worth checking against where Electra actually sells.

## How "Most Liked" Is Defined

"Most liked" brand and category are measured by **total quantity sold**, not by number of orders.

## Files

| File | Description |
|---|---|
| `BikeStore_Analysis.sql` | All 23 queries, commented and grouped by question |

## How to Run

1. Load the BikeStores database into SQL Server (SSMS or Azure Data Studio)
2. Update the database name in the `USE` line if yours is different
3. Run the queries one by one

## Author

**Ziad Amr** - [LinkedIn](www.linkedin.com/in/ziadamrr)
