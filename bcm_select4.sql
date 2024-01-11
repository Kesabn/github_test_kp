-- Q4 ***********************************************************************
/*
Report displaying a summary of Orders with their corresponding list of distinct invoices 
and their total amount 
*/
     SELECT DISTINCT
         h.poh_ord_no,
         h.poh_ord_dt,
         mcb.bcm_main.get_po_serial (h.poh_ord_no)
             order_reference,
         TO_CHAR (h.poh_ord_dt, 'MON-YY')
             order_period,
         h.poh_ord_desc,
         INITCAP (mcb.bcm_main.get_supplier_name (h.supp_id))
             supplier_name,
         TO_CHAR (h.poh_ord_total_amt, '99,999,990.00')
             order_total_amount,
         h.poh_ord_status
             ord_status,
         v.inv_ref
             invoice_reference,
         v.inv_dt,
         TO_CHAR (v.inv_amt, '99,999,990.00')
             invoice_amount,
         --l.pol_ord_ref,
         mcb.bcm_main.get_action (v.pol_ord_ref, v.inv_status)
             action
    FROM po_headers h, po_lines l, po_invoices v
   WHERE     h.poh_ord_no = SUBSTR (l.pol_ord_ref, 1, 5)
         AND l.pol_ord_ref = v.pol_ord_ref
         AND l.itm_id = v.itm_id
ORDER BY TO_CHAR (TRUNC (h.poh_ord_dt, 'MM'), 'MM-YY') DESC, v.inv_dt


