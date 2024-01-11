-- execute procedure for insert suppliers

DECLARE
    l_return_status   VARCHAR2 (25);
    l_msg_data        VARCHAR2 (200);
BEGIN
    mcb.bcm_main.p_mig_supplier (p_return_status   => l_return_status,
                                  p_msg_data        => l_msg_data);
    DBMS_OUTPUT.put_line ('l_msg_data=' || l_msg_data);
END;

-- execute procedure for insert items
DECLARE
    l_return_status   VARCHAR2 (25);
    l_msg_data        VARCHAR2 (200);
BEGIN
    mcb.bcm_main.p_mig_items (p_return_status   => l_return_status,
                                  p_msg_data        => l_msg_data);
    DBMS_OUTPUT.put_line ('l_msg_data=' || l_msg_data);
END;


-- execute procedure for insert po_orders
DECLARE
    l_return_status   VARCHAR2 (25);
    l_msg_data        VARCHAR2 (200);
BEGIN
    mcb.bcm_main.p_mig_orders (p_return_status   => l_return_status,
                                p_msg_data        => l_msg_data
                               );
    --DBMS_OUTPUT.put_line ('l_msg_data=' || l_msg_data);
END;


