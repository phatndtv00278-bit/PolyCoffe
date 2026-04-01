package servlet;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Product;
import util.AuthUtil;
import util.FileUtil;
import util.ParamUtil;

import java.io.IOException;

@WebServlet("/admin/product")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class ProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    private boolean checkAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!AuthUtil.isLogin(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }

        if (!AuthUtil.isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/access-denied.jsp");
            return false;
        }

        return true;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAdmin(req, resp)) return;

        String action = ParamUtil.getString(req, "action", "").trim();
        System.out.println("PRODUCT ACTION = " + action);

        switch (action.toLowerCase()) {
            case "create":
                createProduct(req);
                break;
            case "update":
                updateProduct(req);
                break;
            case "delete":
                deleteProduct(req);   // xóa thật
                break;
            case "hide":
                hideProduct(req);     // ẩn món
                break;
            case "show":
                showProduct(req);     // hiện món
                break;
            default:
                System.out.println("UNKNOWN ACTION = " + action);
                break;
        }

        String category = ParamUtil.getString(req, "category", "Kopi");
        String keyword = ParamUtil.getString(req, "keyword", "");
        String page = ParamUtil.getString(req, "page", "1");

        resp.sendRedirect(
                req.getContextPath()
                        + "/home?category=" + category
                        + "&keyword=" + keyword
                        + "&page=" + page
        );
    }

    private void createProduct(HttpServletRequest req) throws IOException, ServletException {
        String name = ParamUtil.getString(req, "name", "");
        String description = ParamUtil.getString(req, "description", "");
        double price = ParamUtil.getDouble(req, "price", 0);
        String category = ParamUtil.getString(req, "category", "Kopi");
        String statusValue = ParamUtil.getString(req, "status", "1");
        boolean status = "1".equals(statusValue) || "true".equalsIgnoreCase(statusValue);

        if (name.isBlank() || price <= 0) return;

        Part imagePart = req.getPart("imageFile");
        String imagePath = FileUtil.save(imagePart, getServletContext(), "products");

        Product p = new Product();
        p.setName(name);
        p.setDescription(description);
        p.setPrice(price);
        p.setImageUrl(imagePath);
        p.setCategory(category);
        p.setStatus(status);

        boolean ok = productDAO.insert(p);
        System.out.println("CREATE RESULT = " + ok);
    }

    private void updateProduct(HttpServletRequest req) throws IOException, ServletException {
        int id = ParamUtil.getInt(req, "id", -1);
        if (id <= 0) return;

        Product oldProduct = productDAO.findById(id);
        if (oldProduct == null) return;

        String name = ParamUtil.getString(req, "name", "");
        String description = ParamUtil.getString(req, "description", "");
        double price = ParamUtil.getDouble(req, "price", 0);
        String category = ParamUtil.getString(req, "category", "Kopi");
        String statusValue = ParamUtil.getString(req, "status", "1");
        boolean status = "1".equals(statusValue) || "true".equalsIgnoreCase(statusValue);

        if (name.isBlank() || price <= 0) return;

        Part imagePart = req.getPart("imageFile");
        String newImagePath = FileUtil.save(imagePart, getServletContext(), "products");

        Product p = new Product();
        p.setId(id);
        p.setName(name);
        p.setDescription(description);
        p.setPrice(price);
        p.setCategory(category);
        p.setStatus(status);

        if (newImagePath != null && !newImagePath.isBlank()) {
            try {
                FileUtil.delete(oldProduct.getImageUrl(), getServletContext());
            } catch (Exception e) {
                e.printStackTrace();
            }
            p.setImageUrl(newImagePath);
        } else {
            p.setImageUrl(oldProduct.getImageUrl());
        }

        boolean ok = productDAO.update(p);
        System.out.println("UPDATE RESULT = " + ok);
    }

    // XÓA THẬT
    private void deleteProduct(HttpServletRequest req) {
        int id = ParamUtil.getInt(req, "id", -1);
        System.out.println("DELETE ID = " + id);

        if (id <= 0) return;

        Product oldProduct = productDAO.findById(id);
        if (oldProduct == null) {
            System.out.println("DELETE STOP: PRODUCT NOT FOUND");
            return;
        }

        boolean deleted = productDAO.delete(id);
        System.out.println("DELETE DB RESULT = " + deleted);

        if (deleted) {
            try {
                if (oldProduct.getImageUrl() != null && !oldProduct.getImageUrl().isBlank()) {
                    FileUtil.delete(oldProduct.getImageUrl(), getServletContext());
                    System.out.println("DELETE IMAGE RESULT = OK");
                }
            } catch (Exception e) {
                e.printStackTrace();
                System.out.println("DELETE IMAGE FAILED BUT DB ALREADY DELETED");
            }
        }
    }

    // ẨN MÓN
    private void hideProduct(HttpServletRequest req) {
        int id = ParamUtil.getInt(req, "id", -1);
        System.out.println("HIDE ID = " + id);

        if (id <= 0) return;

        Product product = productDAO.findById(id);
        if (product == null) {
            System.out.println("HIDE STOP: PRODUCT NOT FOUND");
            return;
        }

        product.setStatus(false);
        boolean ok = productDAO.update(product);
        System.out.println("HIDE RESULT = " + ok);
    }

    // HIỆN MÓN
    private void showProduct(HttpServletRequest req) {
        int id = ParamUtil.getInt(req, "id", -1);
        System.out.println("SHOW ID = " + id);

        if (id <= 0) return;

        Product product = productDAO.findById(id);
        if (product == null) {
            System.out.println("SHOW STOP: PRODUCT NOT FOUND");
            return;
        }

        product.setStatus(true);
        boolean ok = productDAO.update(product);
        System.out.println("SHOW RESULT = " + ok);
    }
}