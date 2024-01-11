-- Q5 ***********************************************************************
/*Return details for the THIRD (3rd) highest Order Total Amount from the list. 
Only one record is expected with the following information. 
*/ 
      -- THIRD (3rd) highest Order Total Amount 
   SELECT                                                       --h.poh_ord_no,
         mcb.bcm_main.get_po_serial (h.poh_ord_no)
             order_reference,
         TO_CHAR (h.poh_ord_dt, 'fmMonth fmdd, RRRR')
             order_date,
         UPPER (mcb.bcm_main.get_supplier_name (h.supp_id))
             supplier_name,
         TO_CHAR (h.poh_ord_total_amt, '99,999,990.00')
             order_total_amount,
         h.poh_ord_status
             order_status,
         mcb.bcm_main.get_inv_ref (h.poh_ord_no)
             invoice_references
    FROM po_headers h
   WHERE h.poh_ord_total_amt = mcb.bcm_main.get_third_highest (h.poh_ord_no)
ORDER BY h.poh_ord_total_amt DESC

