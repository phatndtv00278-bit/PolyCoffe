package servlet;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Order;
import model.OrderDetail;
import util.AuthUtil;
import util.ParamUtil;

import java.io.IOException;
import java.util.List;

@WebServlet("/bill")
public class BillServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!AuthUtil.isLogin(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int orderId = ParamUtil.getInt(req, "orderId", -1);
        if (orderId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        Order order = orderDAO.findById(orderId);
        if (order == null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        List<OrderDetail> details = orderDAO.findDetailsByOrderId(orderId);

        req.setAttribute("order", order);
        req.setAttribute("details", details);
        req.getRequestDispatcher("/bill.jsp").forward(req, resp);
    }
}