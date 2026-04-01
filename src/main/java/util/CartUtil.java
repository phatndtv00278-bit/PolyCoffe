package util;

import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.Product;

import java.util.ArrayList;
import java.util.List;

public class CartUtil {

    @SuppressWarnings("unchecked")
    public static List<CartItem> getCart(HttpSession session) {
        Object obj = session.getAttribute("cart");
        if (obj == null) {
            List<CartItem> cart = new ArrayList<>();
            session.setAttribute("cart", cart);
            return cart;
        }
        return (List<CartItem>) obj;
    }

    public static void addToCart(HttpSession session, Product product, String size) {
        List<CartItem> cart = getCart(session);

        for (CartItem item : cart) {
            if (item.getProduct().getId() == product.getId()
                    && item.getSize().equalsIgnoreCase(size)) {
                item.setQuantity(item.getQuantity() + 1);
                session.setAttribute("cart", cart);
                return;
            }
        }

        double price = product.getPrice();

        if (size.equalsIgnoreCase("M")) price += 10000;
        if (size.equalsIgnoreCase("L")) price += 10000;

        cart.add(new CartItem(product, 1, size, price));
        session.setAttribute("cart", cart);
    }

    public static void increase(HttpSession session, int productId, String size) {
        List<CartItem> cart = getCart(session);

        for (CartItem item : cart) {
            if (item.getProduct().getId() == productId
                    && item.getSize().equalsIgnoreCase(size)) {
                item.setQuantity(item.getQuantity() + 1);
                break;
            }
        }

        session.setAttribute("cart", cart);
    }

    public static void decrease(HttpSession session, int productId, String size) {
        List<CartItem> cart = getCart(session);

        for (int i = 0; i < cart.size(); i++) {
            CartItem item = cart.get(i);
            if (item.getProduct().getId() == productId
                    && item.getSize().equalsIgnoreCase(size)) {
                item.setQuantity(item.getQuantity() - 1);
                if (item.getQuantity() <= 0) {
                    cart.remove(i);
                }
                break;
            }
        }

        session.setAttribute("cart", cart);
    }

    public static void remove(HttpSession session, int productId, String size) {
        List<CartItem> cart = getCart(session);
        cart.removeIf(item ->
                item.getProduct().getId() == productId
                        && item.getSize().equalsIgnoreCase(size)
        );
        session.setAttribute("cart", cart);
    }

    public static int getTotalQuantity(HttpSession session) {
        List<CartItem> cart = getCart(session);
        int total = 0;
        for (CartItem item : cart) {
            total += item.getQuantity();
        }
        return total;
    }

    public static double getTotalAmount(HttpSession session) {
        List<CartItem> cart = getCart(session);
        double total = 0;
        for (CartItem item : cart) {
            total += item.getProduct().getPrice() * item.getQuantity();
        }
        return total;
    }

    public static void clear(HttpSession session) {
        session.removeAttribute("cart");
    }
}