package servlet;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Order;
import util.CartUtil;

import java.io.IOException;

@WebServlet("/payos-return")
public class PayOSReturnServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();

        String orderCodeStr = req.getParameter("orderCode");
        if (orderCodeStr == null || orderCodeStr.isBlank()) {
            session.setAttribute("successMessage", "Không nhận được mã thanh toán từ PayOS.");
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        try {
            long orderCode = Long.parseLong(orderCodeStr);
            Order order = orderDAO.findByPayOSOrderCode(orderCode);

            if (order != null && "PAID".equalsIgnoreCase(order.getStatus())) {
                CartUtil.clear(session);
                resp.sendRedirect(req.getContextPath() + "/bill?orderId=" + order.getId());
                return;
            } else {
                session.setAttribute("successMessage", "Đơn hàng đang chờ PayOS xác nhận thanh toán.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("successMessage", "Có lỗi khi xử lý kết quả thanh toán.");
        }

        resp.sendRedirect(req.getContextPath() + "/home");
    }
}