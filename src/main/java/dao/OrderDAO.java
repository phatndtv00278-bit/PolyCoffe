package dao;

import model.CartItem;
import model.Order;
import model.OrderDetail;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    public int createCashOrder(int userId, double totalAmount, List<CartItem> cart) {
        String insertOrderSql = """
                INSERT INTO orders(user_id, total_amount, status, payment_method, paid_at)
                VALUES (?, ?, 'PAID', 'CASH', GETDATE())
                """;

        String insertDetailSql = """
                INSERT INTO order_details(order_id, product_id, product_name, size, price, quantity, line_total)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """;

        Connection conn = null;
        PreparedStatement orderPs = null;
        PreparedStatement detailPs = null;
        ResultSet generatedKeys = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            orderPs = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);
            orderPs.setInt(1, userId);
            orderPs.setDouble(2, totalAmount);
            orderPs.executeUpdate();

            generatedKeys = orderPs.getGeneratedKeys();
            int orderId = -1;
            if (generatedKeys.next()) {
                orderId = generatedKeys.getInt(1);
            }

            if (orderId <= 0) {
                conn.rollback();
                return -1;
            }

            detailPs = conn.prepareStatement(insertDetailSql);
            for (CartItem item : cart) {
                double lineTotal = item.getProduct().getPrice() * item.getQuantity();

                detailPs.setInt(1, orderId);
                detailPs.setInt(2, item.getProduct().getId());
                detailPs.setString(3, item.getProduct().getName());
                detailPs.setString(4, item.getSize());
                detailPs.setDouble(5, item.getProduct().getPrice());
                detailPs.setInt(6, item.getQuantity());
                detailPs.setDouble(7, lineTotal);
                detailPs.addBatch();
            }

            detailPs.executeBatch();
            conn.commit();
            return orderId;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } finally {
            try { if (generatedKeys != null) generatedKeys.close(); } catch (Exception ignored) {}
            try { if (orderPs != null) orderPs.close(); } catch (Exception ignored) {}
            try { if (detailPs != null) detailPs.close(); } catch (Exception ignored) {}
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {}
        }

        return -1;
    }

    public int createPendingQrOrder(int userId, double totalAmount, List<CartItem> cart, long payosOrderCode) {
        String insertOrderSql = """
                INSERT INTO orders(user_id, total_amount, status, payment_method, payos_order_code)
                VALUES (?, ?, 'PENDING', 'QR', ?)
                """;

        String insertDetailSql = """
                INSERT INTO order_details(order_id, product_id, product_name, size, price, quantity, line_total)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """;

        Connection conn = null;
        PreparedStatement orderPs = null;
        PreparedStatement detailPs = null;
        ResultSet generatedKeys = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            orderPs = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);
            orderPs.setInt(1, userId);
            orderPs.setDouble(2, totalAmount);
            orderPs.setLong(3, payosOrderCode);
            orderPs.executeUpdate();

            generatedKeys = orderPs.getGeneratedKeys();
            int orderId = -1;
            if (generatedKeys.next()) {
                orderId = generatedKeys.getInt(1);
            }

            if (orderId <= 0) {
                conn.rollback();
                return -1;
            }

            detailPs = conn.prepareStatement(insertDetailSql);
            for (CartItem item : cart) {
                double lineTotal = item.getProduct().getPrice() * item.getQuantity();

                detailPs.setInt(1, orderId);
                detailPs.setInt(2, item.getProduct().getId());
                detailPs.setString(3, item.getProduct().getName());
                detailPs.setString(4, item.getSize());
                detailPs.setDouble(5, item.getProduct().getPrice());
                detailPs.setInt(6, item.getQuantity());
                detailPs.setDouble(7, lineTotal);
                detailPs.addBatch();
            }

            detailPs.executeBatch();
            conn.commit();
            return orderId;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } finally {
            try { if (generatedKeys != null) generatedKeys.close(); } catch (Exception ignored) {}
            try { if (orderPs != null) orderPs.close(); } catch (Exception ignored) {}
            try { if (detailPs != null) detailPs.close(); } catch (Exception ignored) {}
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {}
        }

        return -1;
    }

    public boolean saveCheckoutUrl(long payosOrderCode, String checkoutUrl) {
        String sql = "UPDATE orders SET payos_checkout_url = ? WHERE payos_order_code = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, checkoutUrl);
            ps.setLong(2, payosOrderCode);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean markOrderPaidByPayOSCode(long payosOrderCode) {
        String sql = """
                UPDATE orders
                SET status = 'PAID',
                    paid_at = GETDATE()
                WHERE payos_order_code = ?
                  AND status <> 'PAID'
                """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, payosOrderCode);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public Order findByPayOSOrderCode(long payosOrderCode) {
        String sql = """
                SELECT o.*, u.full_name
                FROM orders o
                JOIN users u ON o.user_id = u.id
                WHERE o.payos_order_code = ?
                """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, payosOrderCode);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setUserId(rs.getInt("user_id"));
                o.setUserFullName(rs.getString("full_name"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setCreatedAt(rs.getTimestamp("created_at"));
                o.setStatus(rs.getString("status"));
                o.setPaymentMethod(rs.getString("payment_method"));

                long code = rs.getLong("payos_order_code");
                if (!rs.wasNull()) o.setPayosOrderCode(code);

                o.setPayosCheckoutUrl(rs.getString("payos_checkout_url"));
                o.setPaidAt(rs.getTimestamp("paid_at"));
                return o;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public int createOrder(int userId, double totalAmount, List<CartItem> cart) {
        return createCashOrder(userId, totalAmount, cart);
    }

    public List<Order> findAll() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.full_name FROM orders o JOIN users u ON o.user_id = u.id ORDER BY o.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setUserId(rs.getInt("user_id"));
                o.setUserFullName(rs.getString("full_name"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setCreatedAt(rs.getTimestamp("created_at"));
                o.setStatus(rs.getString("status"));
                o.setPaymentMethod(rs.getString("payment_method"));

                long code = rs.getLong("payos_order_code");
                if (!rs.wasNull()) o.setPayosOrderCode(code);

                o.setPayosCheckoutUrl(rs.getString("payos_checkout_url"));
                o.setPaidAt(rs.getTimestamp("paid_at"));
                list.add(o);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Order> findRecent(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT TOP (?) o.*, u.full_name FROM orders o JOIN users u ON o.user_id = u.id ORDER BY o.id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setUserId(rs.getInt("user_id"));
                o.setUserFullName(rs.getString("full_name"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setCreatedAt(rs.getTimestamp("created_at"));
                o.setStatus(rs.getString("status"));
                o.setPaymentMethod(rs.getString("payment_method"));

                long code = rs.getLong("payos_order_code");
                if (!rs.wasNull()) o.setPayosOrderCode(code);

                o.setPayosCheckoutUrl(rs.getString("payos_checkout_url"));
                o.setPaidAt(rs.getTimestamp("paid_at"));
                list.add(o);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<OrderDetail> findDetailsByOrderId(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM order_details WHERE order_id = ? ORDER BY id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderDetail d = new OrderDetail();
                d.setId(rs.getInt("id"));
                d.setOrderId(rs.getInt("order_id"));
                d.setProductId(rs.getInt("product_id"));
                d.setProductName(rs.getString("product_name"));
                d.setSize(rs.getString("size"));
                d.setPrice(rs.getDouble("price"));
                d.setQuantity(rs.getInt("quantity"));
                d.setLineTotal(rs.getDouble("line_total"));
                list.add(d);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countOrders() {
        String sql = "SELECT COUNT(*) FROM orders";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public double sumRevenue() {
        String sql = "SELECT ISNULL(SUM(total_amount), 0) FROM orders WHERE status = 'PAID'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getDouble(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public double sumRevenueToday() {
        String sql = """
                SELECT ISNULL(SUM(total_amount), 0)
                FROM orders
                WHERE status = 'PAID'
                  AND CAST(created_at AS DATE) = CAST(GETDATE() AS DATE)
                """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getDouble(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public void updateStatusByPayOS(long orderCode, String status) {
        String sql = "UPDATE orders SET status = ?, paid_at = GETDATE() WHERE payos_order_code = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setLong(2, orderCode);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int countOrdersByDateRange(String fromDate, String toDate) {
        String sql = """
            SELECT COUNT(*)
            FROM orders
            WHERE status = 'PAID'
              AND CAST(created_at AS DATE) BETWEEN ? AND ?
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fromDate);
            ps.setString(2, toDate);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public double sumRevenueByDateRange(String fromDate, String toDate) {
        String sql = """
            SELECT ISNULL(SUM(total_amount), 0)
            FROM orders
            WHERE status = 'PAID'
              AND CAST(created_at AS DATE) BETWEEN ? AND ?
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fromDate);
            ps.setString(2, toDate);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<Order> findOrdersByDateRange(String fromDate, String toDate) {
        List<Order> list = new ArrayList<>();
        String sql = """
            SELECT o.*, u.full_name
            FROM orders o
            JOIN users u ON o.user_id = u.id
            WHERE o.status = 'PAID'
              AND CAST(o.created_at AS DATE) BETWEEN ? AND ?
            ORDER BY o.id DESC
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fromDate);
            ps.setString(2, toDate);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setUserId(rs.getInt("user_id"));
                o.setUserFullName(rs.getString("full_name"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setCreatedAt(rs.getTimestamp("created_at"));
                o.setStatus(rs.getString("status"));
                o.setPaymentMethod(rs.getString("payment_method"));

                long code = rs.getLong("payos_order_code");
                if (!rs.wasNull()) o.setPayosOrderCode(code);

                o.setPayosCheckoutUrl(rs.getString("payos_checkout_url"));
                o.setPaidAt(rs.getTimestamp("paid_at"));
                list.add(o);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Order findById(int orderId) {
        String sql = """
            SELECT o.*, u.full_name
            FROM orders o
            JOIN users u ON o.user_id = u.id
            WHERE o.id = ?
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setUserId(rs.getInt("user_id"));
                o.setUserFullName(rs.getString("full_name"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setCreatedAt(rs.getTimestamp("created_at"));
                o.setStatus(rs.getString("status"));
                o.setPaymentMethod(rs.getString("payment_method"));

                long code = rs.getLong("payos_order_code");
                if (!rs.wasNull()) o.setPayosOrderCode(code);

                o.setPayosCheckoutUrl(rs.getString("payos_checkout_url"));
                o.setPaidAt(rs.getTimestamp("paid_at"));
                return o;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<Order> findByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = """
            SELECT o.*, u.full_name
            FROM orders o
            JOIN users u ON o.user_id = u.id
            WHERE o.user_id = ?
            ORDER BY o.id DESC
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setUserId(rs.getInt("user_id"));
                o.setUserFullName(rs.getString("full_name"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setCreatedAt(rs.getTimestamp("created_at"));
                o.setStatus(rs.getString("status"));
                o.setPaymentMethod(rs.getString("payment_method"));

                long code = rs.getLong("payos_order_code");
                if (!rs.wasNull()) {
                    o.setPayosOrderCode(code);
                }

                o.setPayosCheckoutUrl(rs.getString("payos_checkout_url"));
                o.setPaidAt(rs.getTimestamp("paid_at"));
                list.add(o);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<OrderDetail> findDetailsByOrderIdAndUserId(int orderId, int userId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = """
            SELECT od.*
            FROM order_details od
            JOIN orders o ON od.order_id = o.id
            WHERE od.order_id = ? AND o.user_id = ?
            ORDER BY od.id ASC
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, userId);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderDetail d = new OrderDetail();
                d.setId(rs.getInt("id"));
                d.setOrderId(rs.getInt("order_id"));
                d.setProductId(rs.getInt("product_id"));
                d.setProductName(rs.getString("product_name"));
                d.setSize(rs.getString("size"));
                d.setPrice(rs.getDouble("price"));
                d.setQuantity(rs.getInt("quantity"));
                d.setLineTotal(rs.getDouble("line_total"));
                list.add(d);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Order findByIdAndUserId(int orderId, int userId) {
        String sql = """
            SELECT o.*, u.full_name
            FROM orders o
            JOIN users u ON o.user_id = u.id
            WHERE o.id = ? AND o.user_id = ?
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, userId);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setUserId(rs.getInt("user_id"));
                o.setUserFullName(rs.getString("full_name"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setCreatedAt(rs.getTimestamp("created_at"));
                o.setStatus(rs.getString("status"));
                o.setPaymentMethod(rs.getString("payment_method"));

                long code = rs.getLong("payos_order_code");
                if (!rs.wasNull()) {
                    o.setPayosOrderCode(code);
                }

                o.setPayosCheckoutUrl(rs.getString("payos_checkout_url"));
                o.setPaidAt(rs.getTimestamp("paid_at"));
                return o;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}