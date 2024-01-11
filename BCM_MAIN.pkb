CREATE OR REPLACE PACKAGE BODY MCB.bcm_main
AS
    FUNCTION get_inv_ref (p_ord_no VARCHAR2)
        RETURN VARCHAR2
    IS
        l_invoice_ref   VARCHAR2 (100) := ' ';

        CURSOR c1 IS
            SELECT DISTINCT v.inv_ref
              FROM po_invoices v
             WHERE SUBSTR (v.pol_ord_no, 1, 5) = p_ord_no;
    BEGIN
        FOR i IN c1
        LOOP
            l_invoice_ref := l_invoice_ref || i.inv_ref || ', ';
        END LOOP;

        RETURN RTRIM (LTRIM (l_invoice_ref), ', ');
    END;

    FUNCTION get_supp_first_contact (p_supp_id NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR c1 IS
            SELECT REPLACE (REPLACE (s.supp_contact_no, ' '), '.')    contact_num
              FROM po_suppliers s
             WHERE s.supp_id = p_supp_id;

        l_position            NUMBER;
        l_first_contact_num   VARCHAR2 (10);
    BEGIN
        FOR i IN c1
        LOOP
            l_position := INSTR (i.contact_num, ',');

            IF l_position = 0
            THEN
                l_first_contact_num := i.contact_num;
            ELSIF l_position <> 0
            THEN
                l_first_contact_num :=
                    SUBSTR (i.contact_num, 1, INSTR (i.contact_num, ',') - 1);
            END IF;

            IF LENGTH (l_first_contact_num) = 7
            THEN                                                   -- landline
                -- l_first_contact_num :=
                --TO_CHAR (l_first_contact_num, '999-9999');

                l_first_contact_num :=
                    REGEXP_REPLACE (l_first_contact_num,
                                    '([0-9]{3})([0-9]{4})',
                                    '\1-\2');
            ELSIF LENGTH (l_first_contact_num) = 8
            THEN                                                     -- mobile
                --l_first_contact_num :=
                --TO_CHAR (l_first_contact_num, '5999-9999');

                l_first_contact_num :=
                    REGEXP_REPLACE (l_first_contact_num,
                                    '([0-9]{4})([0-9]{4})',
                                    '\1-\2');
            END IF;
        END LOOP;

        RETURN l_first_contact_num;
    END;


    FUNCTION get_supp_second_contact (p_supp_id NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR c1 IS
            SELECT REPLACE (REPLACE (s.supp_contact_no, ' '), '.')    contact_num
              FROM po_suppliers s
             WHERE s.supp_id = p_supp_id;

        l_position             NUMBER;
        l_second_contact_num   VARCHAR2 (10);
    BEGIN
        FOR i IN c1
        LOOP
            l_position := INSTR (i.contact_num, ',');

            IF l_position = 0
            THEN
                l_second_contact_num := NULL;
            ELSIF l_position <> 0
            THEN
                l_second_contact_num :=
                    SUBSTR (i.contact_num,
                            INSTR (i.contact_num, ',') + 1,
                            LENGTH (i.contact_num));
            END IF;


            IF LENGTH (l_second_contact_num) = 7
            THEN                                                   -- landline
                l_second_contact_num :=
                    REGEXP_REPLACE (l_second_contact_num,
                                    '([0-9]{3})([0-9]{4})',
                                    '\1-\2');
            ELSIF LENGTH (l_second_contact_num) = 8
            THEN                                                     -- mobile
                l_second_contact_num :=
                    REGEXP_REPLACE (l_second_contact_num,
                                    '([0-9]{4})([0-9]{4})',
                                    '\1-\2');
            END IF;
        END LOOP;

        RETURN l_second_contact_num;
    END;

    FUNCTION get_count_orders (p_ord_no VARCHAR2)
        RETURN NUMBER
    IS
        CURSOR c1 IS
            SELECT NVL (COUNT (l.pol_ord_no), 0)     cnt_orders
              FROM po_lines l
             WHERE     SUBSTR (l.pol_ord_no, 1, 5) = p_ord_no
                   AND l.pol_ord_line_status <> 'Cancelled';
    BEGIN
        FOR i IN c1
        LOOP
            RETURN i.cnt_orders;
        END LOOP;

        RETURN -1;
    END;

    FUNCTION get_third_highest (p_ord_no VARCHAR2)
        RETURN NUMBER
    IS
        CURSOR c1 IS
            SELECT MIN (x.total_amt)     total_amt
              FROM (  SELECT DISTINCT h.poh_ord_total_amt     total_amt
                        FROM po_headers h
                    ORDER BY h.poh_ord_total_amt DESC) x
             WHERE ROWNUM < 4;
    BEGIN
        FOR i IN c1
        LOOP
            RETURN i.total_amt;
        END LOOP;

        RETURN -1;
    END;


    FUNCTION get_po_serial (p_order_no VARCHAR2)
        RETURN NUMBER
    IS
        CURSOR c1 IS
            SELECT TO_NUMBER (SUBSTR (SUBSTR (h.poh_ord_no, 1, 5), 3, 5))    po_serial
              FROM po_headers h
             WHERE h.poh_ord_no = p_order_no;
    BEGIN
        FOR i IN c1
        LOOP
            RETURN i.po_serial;
        END LOOP;

        RETURN -1;
    END;

    FUNCTION get_action (p_ord_no VARCHAR2, p_inv_status VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR c1 IS
            SELECT DECODE (UPPER (v.inv_status),
                           'PAID', 'OK',
                           'PENDING', 'TO FOLLOW-UP',
                           ' ', 'TO VERIFY')    action_status
              FROM po_invoices v
             WHERE v.pol_ord_no = p_ord_no;
    BEGIN
        FOR i IN c1
        LOOP
            RETURN i.action_status;
        END LOOP;

        RETURN ' ';
    END;


    FUNCTION get_amt_replaced (p_amt VARCHAR2)
        RETURN NUMBER
    IS
        p_amt_replaced   NUMBER;
        p_result         VARCHAR2 (2);
        p_symbol         VARCHAR2 (2);
    BEGIN
        p_amt_replaced :=
            TO_NUMBER (
                REPLACE (
                    REPLACE (REPLACE (REPLACE (p_amt, ','), 'I', 1), 'o', 0),
                    'S',
                    5));


        RETURN p_amt_replaced;
    END;

    FUNCTION get_supp_id (p_supp_name VARCHAR2)
        RETURN NUMBER
    IS
        CURSOR c1 IS
            SELECT s.supp_id
              FROM po_suppliers s
             WHERE s.supp_name = p_supp_name;
    BEGIN
        FOR i IN c1
        LOOP
            RETURN i.supp_id;
        END LOOP;

        RETURN 0;
    END;


    FUNCTION get_supplier_name (p_supp_id NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR c1 IS
            SELECT s.supp_name
              FROM po_suppliers s
             WHERE s.supp_id = p_supp_id;
    BEGIN
        FOR i IN c1
        LOOP
            RETURN i.supp_name;
        END LOOP;

        RETURN ' ';
    END;

    FUNCTION get_itm_id (p_itm_desc VARCHAR2)
        RETURN NUMBER
    IS
        CURSOR c1 IS
            SELECT i.itm_id
              FROM po_items i
             WHERE i.itm_desc = UPPER(p_itm_desc);
    BEGIN
        FOR i IN c1
        LOOP
            RETURN i.itm_id;
        END LOOP;

        RETURN 0;
    END;

    PROCEDURE p_mig_orders (p_return_status   OUT VARCHAR2,
                            p_msg_data        OUT VARCHAR2)
    IS
        CURSOR c1 IS
              SELECT t.order_ref,
                     TO_DATE (t.order_date, 'DD/MM/YYYY')
                         ord_dt,
                     t.supplier_name,
                     mcb.bcm_main.get_supp_id (t.supplier_name)
                         supp_id,
                     TO_NUMBER (REPLACE (t.order_total_amount, ','))
                         total_amount,
                     t.order_description,
                     t.order_status
                FROM mcb.xxbcm_order_mgt t
               ---WHERE     t.order_ref LIKE NVL (p_ord_no, '%')
               WHERE     LENGTH (t.order_ref) = 5
                     AND NOT EXISTS
                             (SELECT 1
                                FROM mcb.po_headers h
                               WHERE h.poh_ord_no = t.order_ref)
            ORDER BY t.order_ref;

        CURSOR c2 IS
              SELECT t.order_ref,
                     t.order_description,
                     mcb.bcm_main.get_itm_id (t.order_description)
                         itm_id,
                     t.order_line_amount,
                     mcb.bcm_main.get_amt_replaced (t.order_line_amount)
                         line_amt,
                     t.order_status
                FROM mcb.xxbcm_order_mgt t
               -- WHERE     t.order_ref LIKE NVL (p_ord_no, '%')
               WHERE     LENGTH (t.order_ref) > 5
                     AND NOT EXISTS
                             (SELECT 1
                                FROM po_lines h
                               WHERE h.pol_ord_no = t.order_ref)
            ORDER BY t.order_ref;

        CURSOR c3 IS
              SELECT t.order_ref,
                     mcb.bcm_main.get_itm_id (t.order_description)
                         itm_id,
                     t.invoice_reference
                         invoice_ref,
                     TO_DATE (t.invoice_date, 'DD/MM/YYYY')
                         inv_dt,
                     t.invoice_status,
                     t.invoice_hold_reason,
                     mcb.bcm_main.get_amt_replaced (t.invoice_amount)
                         inv_amount,
                     t.invoice_description
                FROM mcb.xxbcm_order_mgt t
               WHERE     t.invoice_reference IS NOT NULL
                     AND NOT EXISTS
                             (SELECT 1
                                FROM mcb.po_invoices v
                               WHERE     v.inv_ref = t.invoice_reference
                                     AND v.pol_ord_no = t.order_ref)
            ORDER BY t.invoice_reference;
    BEGIN
        -- Initialisation
        p_return_status := 'S';

        IF p_return_status = 'S'
        THEN
            -- insert headers
            BEGIN
                FOR i IN c1
                LOOP
                    mcb.bcm_main.insert_po_headers (
                        p_return_status   => p_return_status,
                        p_msg_data        => p_msg_data,
                        p_type            => 'I',
                        p_ord_no          => i.order_ref,
                        p_ord_dt          => i.ord_dt,
                        p_supp_id         => i.supp_id,
                        p_ord_total_amt   => i.total_amount,
                        p_ord_desc        => i.order_description,
                        p_ord_status      => i.order_status);
                END LOOP;

                -- insert lines
                FOR j IN c2
                LOOP
                    mcb.bcm_main.insert_po_lines (
                        p_return_status     => p_return_status,
                        p_msg_data          => p_msg_data,
                        p_type              => 'I',
                        p_ord_no            => j.order_ref,
                        p_itm_id            => j.itm_id,
                        p_ord_line_status   => j.order_status,
                        p_ord_line_amt      => j.line_amt);
                END LOOP;

                -- insert invoices
                FOR k IN c3
                LOOP
                    mcb.bcm_main.insert_po_invoices (
                        p_return_status     => p_return_status,
                        p_msg_data          => p_msg_data,
                        p_type              => 'I',
                        p_inv_ref           => k.invoice_ref,
                        p_inv_dt            => k.inv_dt,
                        p_ord_no            => k.order_ref,
                        p_itm_id            => k.itm_id,
                        p_inv_status        => k.invoice_status,
                        p_inv_hold_reason   => k.invoice_hold_reason,
                        p_inv_amt           => k.inv_amount,
                        p_inv_desc          => k.invoice_description);
                END LOOP;

                COMMIT;

                p_msg_data := 'Processing completed';
                DBMS_OUTPUT.put_line (p_msg_data);
            END;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_return_status := 'F';
            p_msg_data := 'Error @ ' || SQLERRM;
    END;


    PROCEDURE p_mig_supplier (p_return_status   OUT VARCHAR2,
                              p_msg_data        OUT VARCHAR2)
    IS
        CURSOR c1 IS
              SELECT DISTINCT t.supplier_name,
                              t.supp_contact_name,
                              t.supp_address,
                              t.supp_contact_number,
                              t.supp_email
                FROM mcb.xxbcm_order_mgt t
            ORDER BY 1;
    BEGIN
        -- Initialisation
        p_return_status := 'S';

        IF p_return_status = 'S'
        THEN
            BEGIN
                FOR i IN c1
                LOOP
                    mcb.bcm_main.insert_po_suppliers (
                        p_return_status       => p_return_status,
                        p_msg_data            => p_msg_data,
                        p_type                => 'I',
                        p_supp_name           => i.supplier_name,
                        p_supp_contact_name   => i.supp_contact_name,
                        p_supp_address        => i.supp_address,
                        p_supp_contact_no     => i.supp_contact_number,
                        p_supp_mobile_no      => NULL,
                        p_supp_landline_no    => NULL,
                        p_supp_email          => i.supp_email);
                END LOOP;

                COMMIT;

                p_msg_data := 'Processing completed';
                DBMS_OUTPUT.put_line (p_msg_data);
            END;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_return_status := 'F';
            p_msg_data := 'Error @ ' || SQLERRM;
    END;

    PROCEDURE p_mig_items (p_return_status   OUT VARCHAR2,
                           p_msg_data        OUT VARCHAR2)
    IS
        CURSOR c1 IS
              SELECT DISTINCT (t.order_description)     item_desc
                FROM mcb.xxbcm_order_mgt t
               WHERE t.order_line_amount IS NOT NULL
            --WHERE LENGTH (t.order_ref) > 5
            ORDER BY t.order_description;
    BEGIN
        -- Initialisation
        p_return_status := 'S';

        IF p_return_status = 'S'
        THEN
            BEGIN
                FOR i IN c1
                LOOP
                    mcb.bcm_main.insert_po_items (
                        p_return_status   => p_return_status,
                        p_msg_data        => p_msg_data,
                        p_type            => 'I',
                        p_itm_desc        => UPPER(i.item_desc));
                END LOOP;

                COMMIT;

                p_msg_data := 'Processing completed';
                DBMS_OUTPUT.put_line (p_msg_data);
            END;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_return_status := 'F';
            p_msg_data := 'Error @ ' || SQLERRM;
    END;

    PROCEDURE insert_po_headers (p_return_status   OUT VARCHAR2,
                                 p_msg_data        OUT VARCHAR2,
                                 p_type                VARCHAR2,
                                 p_ord_no              VARCHAR2,
                                 p_ord_dt              DATE,
                                 p_supp_id             NUMBER,
                                 p_ord_total_amt       NUMBER,
                                 p_ord_desc            VARCHAR2,
                                 p_ord_status          VARCHAR2)
    IS
    BEGIN
        p_return_status := 'S';

        BEGIN
            IF p_return_status = 'S' AND p_type = 'I'
            THEN
                INSERT INTO mcb.po_headers (poh_ord_no,
                                             poh_ord_dt,
                                             supp_id,
                                             poh_ord_total_amt,
                                             poh_ord_desc,
                                             poh_ord_status)
                     VALUES (p_ord_no,
                             p_ord_dt,
                             p_supp_id,
                             p_ord_total_amt,
                             p_ord_desc,
                             p_ord_status);
            END IF;

            COMMIT;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
                --p_return_status := 'F';
                INSERT INTO tmp_ins_msg (msg, entity)
                         VALUES (
                                       'Duplicate value for Order found -'
                                    || p_ord_no,
                                    'BCM_ORD');

                p_msg_data := 'Duplicate value for Order found -' || p_ord_no;
            WHEN OTHERS
            THEN
                p_return_status := 'F';
                p_msg_data := 'Error occured @' || SQLERRM;
        END;
    END;

    PROCEDURE insert_po_lines (p_return_status     OUT VARCHAR2,
                               p_msg_data          OUT VARCHAR2,
                               p_type                  VARCHAR2,
                               p_ord_no                VARCHAR2,
                               p_itm_id                NUMBER,
                               p_ord_line_status       VARCHAR2,
                               p_ord_line_amt          NUMBER)
    IS
        l_line_no   NUMBER;
    BEGIN
        p_return_status := 'S';

        BEGIN
            IF p_return_status = 'S' AND p_type = 'I'
            THEN
                SELECT NVL (MAX (l.pol_ord_line), 0) + 10
                  INTO l_line_no
                  FROM mcb.po_lines l
                 WHERE l.pol_ord_no = p_ord_no;

                INSERT INTO mcb.po_lines (pol_ord_no,
                                           pol_ord_line,
                                           itm_id,
                                           pol_ord_line_status,
                                           pol_ord_line_amt)
                     VALUES (p_ord_no,
                             l_line_no,
                             p_itm_id,
                             p_ord_line_status,
                             p_ord_line_amt);
            END IF;

            COMMIT;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
                --p_return_status := 'F';
                INSERT INTO tmp_ins_msg (msg, entity)
                         VALUES (
                                       'Duplicate value for Order Line found -'
                                    || p_ord_no,
                                    'BCM_ORD_LINE');

                p_msg_data :=
                    'Duplicate value for Order Line found -' || p_ord_no;
            WHEN OTHERS
            THEN
                p_return_status := 'F';
                p_msg_data := 'Error occured @' || SQLERRM;
        END;
    END;


    PROCEDURE insert_po_invoices (p_return_status     OUT VARCHAR2,
                                  p_msg_data          OUT VARCHAR2,
                                  p_type                  VARCHAR2,
                                  p_inv_ref               VARCHAR2,
                                  p_inv_dt                DATE,
                                  p_ord_no                VARCHAR2,
                                  p_itm_id                NUMBER,
                                  p_inv_status            VARCHAR2,
                                  p_inv_hold_reason       VARCHAR2,
                                  p_inv_amt               NUMBER,
                                  p_inv_desc              VARCHAR2)
    IS
    BEGIN
        p_return_status := 'S';

        BEGIN
            IF p_return_status = 'S' AND p_type = 'I'
            THEN
                INSERT INTO mcb.po_invoices (inv_ref,
                                              inv_dt,
                                              pol_ord_no,
                                              itm_id,
                                              inv_status,
                                              inv_hold_reason,
                                              inv_amt,
                                              inv_desc)
                     VALUES (p_inv_ref,
                             p_inv_dt,
                             p_ord_no,
                             p_itm_id,
                             p_inv_status,
                             p_inv_hold_reason,
                             p_inv_amt,
                             p_inv_desc);
            END IF;

            COMMIT;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
                --p_return_status := 'F';
                INSERT INTO tmp_ins_msg (msg, entity)
                         VALUES (
                                       'Duplicate value for invoice found -'
                                    || p_inv_ref,
                                    'BCM_INVOICES');

                p_msg_data :=
                    'Duplicate value for invoice found -' || p_inv_ref;
            WHEN OTHERS
            THEN
                p_return_status := 'F';
                p_msg_data := 'Error occured @' || SQLERRM;
        END;
    END;



    PROCEDURE insert_po_suppliers (p_return_status       OUT VARCHAR2,
                                   p_msg_data            OUT VARCHAR2,
                                   p_type                    VARCHAR2,
                                   p_supp_name               VARCHAR2,
                                   p_supp_contact_name       VARCHAR2,
                                   p_supp_address            VARCHAR2,
                                   p_supp_contact_no         VARCHAR2,
                                   p_supp_mobile_no          NUMBER,
                                   p_supp_landline_no        NUMBER,
                                   p_supp_email              VARCHAR2)
    IS
        l_seq_no   NUMBER;
    BEGIN
        p_return_status := 'S';

        BEGIN
            IF p_return_status = 'S' AND p_type = 'I'
            THEN
                SELECT NVL (MAX (s.supp_id), 100) + 1
                  INTO l_seq_no
                  FROM mcb.po_suppliers s;

                INSERT INTO mcb.po_suppliers (supp_id,
                                               supp_name,
                                               supp_contact_name,
                                               supp_address,
                                               supp_contact_no,
                                               supp_mobile_no,
                                               supp_landline_no,
                                               supp_email)
                     VALUES (l_seq_no,
                             p_supp_name,
                             p_supp_contact_name,
                             p_supp_address,
                             p_supp_contact_no,
                             p_supp_mobile_no,
                             p_supp_landline_no,
                             p_supp_email);
            END IF;

            COMMIT;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
                --p_return_status := 'F';
                INSERT INTO tmp_ins_msg (msg, entity)
                         VALUES (
                                       'Duplicate value for supplier found -'
                                    || p_supp_name,
                                    'BCM_SUPP');

                p_msg_data :=
                    'Duplicate value for supplier found -' || p_supp_name;
            WHEN OTHERS
            THEN
                p_return_status := 'F';
                p_msg_data := 'Error occured @' || SQLERRM;
        END;
    END;

    PROCEDURE insert_po_items (p_return_status   OUT VARCHAR2,
                               p_msg_data        OUT VARCHAR2,
                               p_type                VARCHAR2,
                               p_itm_desc            VARCHAR2)
    IS
        l_seq_no   NUMBER;
    BEGIN
        p_return_status := 'S';

        BEGIN
            IF p_return_status = 'S' AND p_type = 'I'
            THEN
                SELECT NVL (MAX (i.itm_id), 1000) + 1
                  INTO l_seq_no
                  FROM mcb.po_items i;

                INSERT INTO mcb.po_items (itm_id, itm_desc)
                     VALUES (l_seq_no, p_itm_desc);
            END IF;

            COMMIT;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
                --p_return_status := 'F';
                INSERT INTO tmp_ins_msg (msg, entity)
                         VALUES (
                                       'Duplicate value for item found -'
                                    || p_itm_desc,
                                    'BCM_ITM');

                p_msg_data :=
                    'Duplicate value for item found -' || p_itm_desc;
            WHEN OTHERS
            THEN
                p_return_status := 'F';
                p_msg_data := 'Error occured @' || SQLERRM;
        END;
    END;


    PROCEDURE p_mig_upd_supplier (p_return_status   OUT VARCHAR2,
                                  p_msg_data        OUT VARCHAR2)
    IS
        CURSOR c1 IS
              SELECT s.supp_id,
                     REPLACE (REPLACE (s.supp_contact_no, ' '), '.')    contact_num
                FROM po_suppliers s
            ORDER BY s.supp_id;

        CURSOR c2 IS
              SELECT s.supp_id,
                     REPLACE (REPLACE (s.supp_contact_no, ' '), '.')    contact_num
                FROM po_suppliers s
            ORDER BY s.supp_id;

        l_position             NUMBER;
        l_first_contact_num    VARCHAR2 (10);
        l_second_contact_num   VARCHAR2 (10);
    BEGIN
        -- Initialisation
        p_return_status := 'S';

        IF p_return_status = 'S'
        THEN
            BEGIN
                FOR i IN c1
                LOOP
                    l_position := INSTR (i.contact_num, ',');

                    IF l_position = 0
                    THEN
                        l_first_contact_num := i.contact_num;
                    ELSIF l_position <> 0
                    THEN
                        l_first_contact_num :=
                            SUBSTR (i.contact_num,
                                    1,
                                    INSTR (i.contact_num, ',') - 1);
                    END IF;

                    IF LENGTH (l_first_contact_num) = 7
                    THEN                                           -- landline
                        UPDATE po_suppliers s
                           SET s.supp_landline_no =
                                   TO_NUMBER (l_first_contact_num)
                         WHERE supp_id = i.supp_id;
                    ELSIF LENGTH (l_first_contact_num) = 8
                    THEN                                             -- mobile
                        UPDATE po_suppliers s
                           SET s.supp_mobile_no =
                                   TO_NUMBER (l_first_contact_num)
                         WHERE supp_id = i.supp_id;
                    END IF;
                END LOOP;

                FOR j IN c2
                LOOP
                    l_position := INSTR (j.contact_num, ',');

                    IF l_position = 0
                    THEN
                        l_second_contact_num := NULL;
                    ELSIF l_position <> 0
                    THEN
                        l_second_contact_num :=
                            SUBSTR (j.contact_num,
                                    INSTR (j.contact_num, ',') + 1,
                                    LENGTH (j.contact_num));
                    END IF;

                    IF LENGTH (l_second_contact_num) = 7
                    THEN                                           -- landline
                        UPDATE po_suppliers s
                           SET s.supp_landline_no =
                                   TO_NUMBER (l_second_contact_num)
                         WHERE supp_id = j.supp_id;
                    ELSIF LENGTH (l_second_contact_num) = 8
                    THEN                                             -- mobile
                        UPDATE po_suppliers s
                           SET s.supp_mobile_no =
                                   TO_NUMBER (l_second_contact_num)
                         WHERE supp_id = j.supp_id;
                    END IF;
                END LOOP;

                COMMIT;

                p_msg_data := 'Processing completed';
                DBMS_OUTPUT.put_line (p_msg_data);
            END;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_return_status := 'F';
            p_msg_data := 'Error @ ' || SQLERRM;
    END;
END;
/
