package servlet;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Order;
import util.AuthUtil;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/dashboard")
public class DashboardServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!AuthUtil.isLogin(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (!AuthUtil.isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/access-denied.jsp");
            return;
        }

        String fromDate = req.getParameter("fromDate");
        String toDate = req.getParameter("toDate");

        boolean hasFilter = fromDate != null && !fromDate.isBlank()
                && toDate != null && !toDate.isBlank();

        int totalOrders;
        double totalRevenue;
        double todayRevenue = orderDAO.sumRevenueToday();
        List<Order> recentOrders;

        if (hasFilter) {
            totalOrders = orderDAO.countOrdersByDateRange(fromDate, toDate);
            totalRevenue = orderDAO.sumRevenueByDateRange(fromDate, toDate);
            recentOrders = orderDAO.findOrdersByDateRange(fromDate, toDate);
        } else {
            totalOrders = orderDAO.countOrders();
            totalRevenue = orderDAO.sumRevenue();
            recentOrders = orderDAO.findRecent(5);
        }

        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("todayRevenue", todayRevenue);
        req.setAttribute("recentOrders", recentOrders);
        req.setAttribute("fromDate", fromDate);
        req.setAttribute("toDate", toDate);
        req.setAttribute("hasFilter", hasFilter);

        req.getRequestDispatcher("/admin-dashboard.jsp").forward(req, resp);
    }
}