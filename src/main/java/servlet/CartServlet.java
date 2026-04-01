package servlet;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.CartItem;
import model.Product;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String category = request.getParameter("category");
        if (category == null || category.isBlank()) {
            category = "Kopi";
        }

        HttpSession session = request.getSession();
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        if ("add".equals(action)) {
            int productId = Integer.parseInt(request.getParameter("productId"));
            String size = request.getParameter("size");
            double price = Double.parseDouble(request.getParameter("price"));

            Product product = productDAO.findById(productId);
            if (product != null) {
                boolean found = false;

                for (CartItem item : cart) {
                    if (item.getProduct().getId() == productId && item.getSize().equalsIgnoreCase(size)) {
                        item.setQuantity(item.getQuantity() + 1);
                        item.setPrice(price);
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    cart.add(new CartItem(product, 1, size, price));
                }
            }
        }

        else if ("increase".equals(action)) {
            int productId = Integer.parseInt(request.getParameter("productId"));
            String size = request.getParameter("size");

            for (CartItem item : cart) {
                if (item.getProduct().getId() == productId && item.getSize().equalsIgnoreCase(size)) {
                    item.setQuantity(item.getQuantity() + 1);
                    break;
                }
            }
        }

        else if ("decrease".equals(action)) {
            int productId = Integer.parseInt(request.getParameter("productId"));
            String size = request.getParameter("size");

            for (int i = 0; i < cart.size(); i++) {
                CartItem item = cart.get(i);
                if (item.getProduct().getId() == productId && item.getSize().equalsIgnoreCase(size)) {
                    if (item.getQuantity() > 1) {
                        item.setQuantity(item.getQuantity() - 1);
                    } else {
                        cart.remove(i);
                    }
                    break;
                }
            }
        }

        else if ("remove".equals(action)) {
            int productId = Integer.parseInt(request.getParameter("productId"));
            String size = request.getParameter("size");

            cart.removeIf(item ->
                    item.getProduct().getId() == productId &&
                            item.getSize().equalsIgnoreCase(size)
            );
        }

        else if ("clear".equals(action)) {
            cart.clear();
        }

        session.setAttribute("cart", cart);
        response.sendRedirect(request.getContextPath() + "/home?category=" + category);
    }
}