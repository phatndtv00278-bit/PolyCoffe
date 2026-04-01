package servlet;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Product;
import model.User;
import util.ParamUtil;

import java.io.IOException;
import java.text.Normalizer;
import java.util.List;
import java.util.Locale;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private static final int PAGE_SIZE = 4;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());

        String category = ParamUtil.getString(req, "category", "").trim();
        String keyword = ParamUtil.getString(req, "keyword", "").trim();
        int page = ParamUtil.getInt(req, "page", 1);

        if (page < 1) page = 1;

        String detectedCategory = detectCategory(keyword);
        if ((category == null || category.isBlank()) && detectedCategory != null) {
            category = detectedCategory;
            keyword = "";
        }

        if ((category == null || category.isBlank()) && (keyword == null || keyword.isBlank())) {
            category = "Kopi";
        }

        int totalProducts = productDAO.countByCategoryAndKeyword(category, keyword, isAdmin);
        int totalPages = (int) Math.ceil((double) totalProducts / PAGE_SIZE);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * PAGE_SIZE;

        List<Product> products = productDAO.findByCategoryAndKeyword(category, keyword, offset, PAGE_SIZE, isAdmin);

        req.setAttribute("products", products);
        req.setAttribute("currentCategory", category);
        req.setAttribute("keyword", keyword);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);

        String editIdRaw = req.getParameter("editId");
        if (editIdRaw != null && !editIdRaw.isBlank()) {
            int editId = Integer.parseInt(editIdRaw);
            Product editProduct = productDAO.findById(editId);
            req.setAttribute("editProduct", editProduct);
        }

        req.getRequestDispatcher("/home.jsp").forward(req, resp);
    }

    private String detectCategory(String keyword) {
        if (keyword == null || keyword.isBlank()) return null;

        String k = normalize(keyword);

        if (k.equals("c")
                || k.equals("ca")
                || k.equals("caf")
                || k.equals("cafe")
                || k.equals("caphe")
                || k.startsWith("ca phe")
                || k.startsWith("coffee")
                || k.startsWith("kopi")) {
            return "Kopi";
        }

        if (k.equals("t")
                || k.equals("tr")
                || k.equals("tra")
                || k.startsWith("tra s")
                || k.startsWith("tra su")
                || k.startsWith("tra sua")
                || k.startsWith("trasua")
                || k.startsWith("milk tea")) {
            return "TraSua";
        }

        if (k.startsWith("tra t")
                || k.startsWith("tra tr")
                || k.startsWith("tra trai")
                || k.startsWith("tra trai cay")
                || k.startsWith("trai cay")
                || k.startsWith("fruit tea")) {
            return "TraTraiCay";
        }

        return null;
    }

    private String normalize(String input) {
        String value = Normalizer.normalize(input, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase(Locale.ROOT)
                .trim();
        value = value.replace('đ', 'd');
        value = value.replaceAll("\\s+", " ");
        return value;
    }
}