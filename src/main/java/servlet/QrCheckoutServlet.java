package servlet;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.CartItem;
import model.User;
import util.AuthUtil;
import util.CartUtil;
import util.PayOSUtil;
import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/checkout/qr/confirm")
public class QrCheckoutServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!AuthUtil.isLogin(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("loggedInUser");
        List<CartItem> cart = CartUtil.getCart(session);

        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        try {
            double totalAmount = CartUtil.getTotalAmount(session);
            long payosOrderCode = System.currentTimeMillis();

            int orderId = orderDAO.createPendingQrOrder(user.getId(), totalAmount, cart, payosOrderCode);
            if (orderId <= 0) {
                session.setAttribute("successMessage", "Không thể tạo hóa đơn QR.");
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }

            String baseUrl = req.getScheme() + "://" + req.getServerName() +
                    ((req.getServerPort() == 80 || req.getServerPort() == 443) ? "" : ":" + req.getServerPort()) +
                    req.getContextPath();

            String returnUrl = baseUrl + "/payos-return";
            String cancelUrl = baseUrl + "/home";

            PayOS payOS = PayOSUtil.getPayOS();

            CreatePaymentLinkRequest paymentRequest = CreatePaymentLinkRequest.builder()
                    .orderCode(payosOrderCode)
                    .amount((long) totalAmount)
                    .description("Thanh toan don " + orderId)
                    .returnUrl(returnUrl)
                    .cancelUrl(cancelUrl)
                    .build();

            CreatePaymentLinkResponse paymentLink = payOS.paymentRequests().create(paymentRequest);

            orderDAO.saveCheckoutUrl(payosOrderCode, paymentLink.getCheckoutUrl());

            resp.sendRedirect(paymentLink.getCheckoutUrl());

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("successMessage", "Lỗi tạo thanh toán PayOS: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }
}