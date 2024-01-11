-- Q6 ***********************************************************************
/* List all suppliers with their respective number of orders and total amount ordered from them 
   between the period of 01 January 2017 and 31 August 2017. 
*/
  
      SELECT x.supplier_name,
         x.supplier_contact_name,
         x.first_contact_num,
         x.second_contact_num,
         NVL (SUM (x.total_orders), 0)                                  total_orders,
         TO_CHAR (NVL (SUM (x.order_total_amt), 0), '99,999,990.00')    order_total_amt
    FROM (  SELECT s.supp_name
                       supplier_name,
                   s.supp_contact_name
                       supplier_contact_name,
                   mcb.bcm_main.get_supp_first_contact (h.supp_id)
                       first_contact_num,
                   mcb.bcm_main.get_supp_second_contact (h.supp_id)
                       second_contact_num,
                   h.poh_ord_no,
                   mcb.bcm_main.get_count_orders (h.poh_ord_no)
                       total_orders,
                   h.poh_ord_total_amt
                       order_total_amt
              FROM po_headers h, po_suppliers s
             WHERE     h.supp_id = s.supp_id
                   AND h.poh_ord_dt BETWEEN '01-JAN-2017' AND '31-AUG-2017'
          ORDER BY s.supp_name, h.poh_ord_no) x
GROUP BY x.supplier_name,
         x.supplier_contact_name,
         x.first_contact_num,
         x.second_contact_num
ORDER BY x.supplier_name

