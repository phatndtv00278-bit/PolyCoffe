package dao;

import model.Product;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public List<Product> findAllActive() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE status = 1 ORDER BY id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Product> findAll() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Product> findByCategory(String category) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE category = ? AND status = 1 ORDER BY id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Product> findAllByCategory(String category) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE category = ? ORDER BY id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Product> findByCategoryAndKeyword(String category, String keyword, int offset, int limit, boolean isAdmin) {
        List<Product> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT * FROM products WHERE 1=1 ");

        if (category != null && !category.isBlank()) {
            sql.append("AND category = ? ");
        }

        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND name LIKE ? ");
        }

        if (!isAdmin) {
            sql.append("AND status = 1 ");
        }

        sql.append("ORDER BY id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int index = 1;

            if (category != null && !category.isBlank()) {
                ps.setString(index++, category);
            }

            if (keyword != null && !keyword.isBlank()) {
                ps.setString(index++, "%" + keyword + "%");
            }

            ps.setInt(index++, offset);
            ps.setInt(index, limit);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countByCategoryAndKeyword(String category, String keyword, boolean isAdmin) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products WHERE 1=1 ");

        if (category != null && !category.isBlank()) {
            sql.append("AND category = ? ");
        }

        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND name LIKE ? ");
        }

        if (!isAdmin) {
            sql.append("AND status = 1 ");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int index = 1;

            if (category != null && !category.isBlank()) {
                ps.setString(index++, category);
            }

            if (keyword != null && !keyword.isBlank()) {
                ps.setString(index, "%" + keyword + "%");
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public Product findById(int id) {
        String sql = "SELECT * FROM products WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapRow(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean insert(Product product) {
        String sql = "INSERT INTO products(name, description, price, image_url, category, status) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, product.getName());
            ps.setString(2, product.getDescription());
            ps.setDouble(3, product.getPrice());
            ps.setString(4, product.getImageUrl());
            ps.setString(5, product.getCategory());
            ps.setBoolean(6, product.isStatus());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean update(Product product) {
        String sql = "UPDATE products SET name = ?, description = ?, price = ?, image_url = ?, category = ?, status = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, product.getName());
            ps.setString(2, product.getDescription());
            ps.setDouble(3, product.getPrice());
            ps.setString(4, product.getImageUrl());
            ps.setString(5, product.getCategory());
            ps.setBoolean(6, product.isStatus());
            ps.setInt(7, product.getId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM products WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private Product mapRow(ResultSet rs) throws Exception {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getDouble("price"));
        p.setImageUrl(rs.getString("image_url"));
        p.setCategory(rs.getString("category"));
        p.setStatus(rs.getBoolean("status"));
        return p;
    }

    public boolean softDelete(int id) {
        String sql = "UPDATE products SET status = 0 WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}