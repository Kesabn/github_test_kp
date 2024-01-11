CREATE OR REPLACE PACKAGE MCB.bcm_main
AS
    FUNCTION get_inv_ref (p_ord_no VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION get_count_orders (p_ord_no VARCHAR2)
        RETURN NUMBER;

    FUNCTION get_supp_first_contact (p_supp_id NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_supp_second_contact (p_supp_id NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_po_serial (p_order_no VARCHAR2)
        RETURN NUMBER;

    FUNCTION get_action (p_ord_no VARCHAR2, p_inv_status VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION get_third_highest (p_ord_no VARCHAR2)
        RETURN NUMBER;

    FUNCTION get_amt_replaced (p_amt VARCHAR2)
        RETURN NUMBER;

    FUNCTION get_supp_id (p_supp_name VARCHAR2)
        RETURN NUMBER;

    FUNCTION get_supplier_name (p_supp_id NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_itm_id (p_itm_desc VARCHAR2)
        RETURN NUMBER;

    PROCEDURE p_mig_orders (p_return_status   OUT VARCHAR2,
                            p_msg_data        OUT VARCHAR2);

    PROCEDURE p_mig_supplier (p_return_status   OUT VARCHAR2,
                              p_msg_data        OUT VARCHAR2);

    PROCEDURE p_mig_items (p_return_status   OUT VARCHAR2,
                           p_msg_data        OUT VARCHAR2);

    PROCEDURE insert_po_headers (p_return_status   OUT VARCHAR2,
                                 p_msg_data        OUT VARCHAR2,
                                 p_type                VARCHAR2,
                                 p_ord_no              VARCHAR2,
                                 p_ord_dt              DATE,
                                 p_supp_id             NUMBER,
                                 p_ord_total_amt       NUMBER,
                                 p_ord_desc            VARCHAR2,
                                 p_ord_status          VARCHAR2);

    PROCEDURE insert_po_invoices (p_return_status     OUT VARCHAR2,
                                  p_msg_data          OUT VARCHAR2,
                                  p_type                  VARCHAR2,
                                  p_inv_ref               VARCHAR2,
                                  p_inv_dt                DATE,
                                  p_ord_ref               VARCHAR2,
                                  p_itm_id                NUMBER,
                                  p_inv_status            VARCHAR2,
                                  p_inv_hold_reason       VARCHAR2,
                                  p_inv_amt               NUMBER,
                                  p_inv_desc              VARCHAR2);


    PROCEDURE insert_po_lines (p_return_status     OUT VARCHAR2,
                               p_msg_data          OUT VARCHAR2,
                               p_type                  VARCHAR2,
                               p_ord_no                VARCHAR2,
                               p_ord_ref               VARCHAR2,
                               p_itm_id                NUMBER,
                               p_ord_line_status       VARCHAR2,
                               p_ord_line_amt          NUMBER);

    PROCEDURE insert_po_suppliers (p_return_status       OUT VARCHAR2,
                                   p_msg_data            OUT VARCHAR2,
                                   p_type                    VARCHAR2,
                                   p_supp_name               VARCHAR2,
                                   p_supp_contact_name       VARCHAR2,
                                   p_supp_address            VARCHAR2,
                                   p_supp_contact_no         VARCHAR2,
                                   p_supp_mobile_no          NUMBER,
                                   p_supp_landline_no        NUMBER,
                                   p_supp_email              VARCHAR2);

    PROCEDURE insert_po_items (p_return_status   OUT VARCHAR2,
                               p_msg_data        OUT VARCHAR2,
                               p_type                VARCHAR2,
                               p_itm_desc            VARCHAR2);

    PROCEDURE p_mig_upd_supplier (p_return_status   OUT VARCHAR2,
                                  p_msg_data        OUT VARCHAR2);
END bcm_main;
/

