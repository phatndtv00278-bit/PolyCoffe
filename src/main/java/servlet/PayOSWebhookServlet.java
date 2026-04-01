package servlet;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet("/payos-webhook")
public class PayOSWebhookServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        StringBuilder sb = new StringBuilder();
        String line;

        try (BufferedReader reader = req.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String body = sb.toString();

        System.out.println("========== PAYOS WEBHOOK ==========");
        System.out.println(body);

        try {
            Long orderCode = extractOrderCode(body);

            if (orderCode == null) {
                System.out.println("Không lấy được orderCode từ webhook");
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy orderCode\"}");
                return;
            }

            System.out.println("orderCode nhận được: " + orderCode);

            orderDAO.updateStatusByPayOS(orderCode, "PAID");

            System.out.println("Đã cập nhật đơn sang PAID cho orderCode: " + orderCode);

            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write("{\"success\":true}");

        } catch (Exception e) {
            System.out.println("Lỗi xử lý webhook PayOS: " + e.getMessage());
            e.printStackTrace();

            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi xử lý webhook\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        resp.getWriter().write("Webhook này chỉ hỗ trợ POST");
    }

    private Long extractOrderCode(String body) {
        if (body == null || body.isBlank()) {
            return null;
        }

        Pattern nestedPattern = Pattern.compile("\"data\"\\s*:\\s*\\{.*?\"orderCode\"\\s*:\\s*(\\d+)", Pattern.DOTALL);
        Matcher nestedMatcher = nestedPattern.matcher(body);
        if (nestedMatcher.find()) {
            return Long.parseLong(nestedMatcher.group(1));
        }

        Pattern topPattern = Pattern.compile("\"orderCode\"\\s*:\\s*(\\d+)");
        Matcher topMatcher = topPattern.matcher(body);
        if (topMatcher.find()) {
            return Long.parseLong(topMatcher.group(1));
        }

        return null;
    }


}