<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderDetail" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }

    List<Order> orders = (List<Order>) request.getAttribute("orders");
    List<OrderDetail> details = (List<OrderDetail>) request.getAttribute("details");
    Integer selectedOrderId = (Integer) request.getAttribute("selectedOrderId");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử mua hàng - PolyCoffee</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        :root {
            --coffee: #8a5a52;
            --coffee-dark: #6d433d;
            --text-dark: #2f2a28;
            --text-soft: #7a6d68;
            --shadow-soft: 0 10px 30px rgba(37, 24, 19, 0.10);
            --radius-xl: 28px;
            --radius-lg: 22px;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: "Segoe UI", Arial, sans-serif;
            background:
                radial-gradient(circle at top left, #efe4dc 0%, transparent 30%),
                radial-gradient(circle at bottom right, #ddd7d1 0%, transparent 28%),
                linear-gradient(135deg, #ece9e6 0%, #ddd8d3 100%);
            color: #fff;
        }

        .dashboard-shell {
            background: linear-gradient(135deg, rgba(113, 84, 78, 0.97), rgba(42, 39, 39, 0.97));
            min-height: calc(100vh - 24px);
            border-radius: 34px;
            overflow: hidden;
            margin: 12px;
            box-shadow: 0 20px 50px rgba(30, 20, 16, 0.22);
        }

        .sidebar {
            width: 102px;
            background: rgba(248, 244, 240, 0.92);
            min-height: calc(100vh - 24px);
            border-right: 1px solid rgba(138, 90, 82, 0.08);
        }

        .logo-circle {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: linear-gradient(135deg, #f3e7df, #d9c9c0);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--coffee);
            font-size: 26px;
            margin: 24px auto 28px;
            box-shadow: 0 10px 22px rgba(138, 90, 82, 0.18);
        }

        .side-icon {
            width: 50px;
            height: 50px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 16px auto;
            color: #625856;
            font-size: 22px;
            text-decoration: none;
            position: relative;
            transition: all 0.25s ease;
        }

        .side-icon:hover {
            background: rgba(138, 90, 82, 0.12);
            color: var(--coffee);
            transform: translateY(-2px);
        }

        .side-icon.active {
            background: linear-gradient(135deg, rgba(138, 90, 82, 0.16), rgba(138, 90, 82, 0.08));
            color: var(--coffee);
            box-shadow: 0 8px 20px rgba(138, 90, 82, 0.12);
        }

        .side-icon.active::after {
            content: "";
            position: absolute;
            right: -13px;
            top: 8px;
            width: 4px;
            height: 34px;
            background: linear-gradient(to bottom, #d78a79, #8a5a52);
            border-radius: 999px;
        }

        .main-content {
            padding: 30px;
            width: 100%;
            color: #fff;
        }

        .hero-panel {
            background: linear-gradient(135deg, rgba(255,255,255,0.10), rgba(255,255,255,0.05));
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: var(--radius-xl);
            padding: 22px 24px;
            box-shadow: 0 12px 24px rgba(0,0,0,0.12);
            margin-bottom: 24px;
        }

        .hero-title {
            font-size: 30px;
            font-weight: 800;
            line-height: 1.2;
            margin-bottom: 6px;
        }

        .profile-chip {
            background: rgba(255,255,255,0.10);
            border: 1px solid rgba(255,255,255,0.10);
            padding: 10px 14px;
            border-radius: 18px;
        }

        .box {
            border-radius: var(--radius-lg);
            border: 1px solid rgba(138, 90, 82, 0.08);
            background: linear-gradient(180deg, #f8f5f2 0%, #f2ece8 100%);
            box-shadow: var(--shadow-soft);
            color: var(--text-dark);
        }

        .section-title {
            font-weight: 800;
            color: var(--text-dark);
        }

        .custom-table {
            margin-bottom: 0;
            overflow: hidden;
            border-radius: 16px;
        }

        .custom-table thead th {
            background: #2f2a28 !important;
            color: #fff !important;
            border: none !important;
            padding: 14px 16px;
        }

        .custom-table tbody td {
            padding: 14px 16px;
            vertical-align: middle;
            border-color: #ece2dc !important;
            color: var(--text-dark);
        }

        .custom-table tbody tr {
            background: rgba(255,255,255,0.72);
        }

        .order-code {
            font-weight: 800;
            color: var(--coffee-dark);
        }

        .money {
            font-weight: 800;
            color: var(--coffee-dark);
        }

        .btn-view {
            background: linear-gradient(135deg, var(--coffee), var(--coffee-dark));
            border: none;
            color: #fff;
            border-radius: 12px;
            font-weight: 700;
            padding: 8px 14px;
            text-decoration: none;
            display: inline-block;
        }

        .btn-view:hover {
            color: #fff;
        }

        .detail-empty {
            min-height: 250px;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: var(--text-soft);
            border: 2px dashed #e3d4cb;
            border-radius: 18px;
            background: rgba(255,255,255,0.65);
            padding: 24px;
        }

        .detail-badge {
            background: linear-gradient(135deg, var(--coffee), var(--coffee-dark));
            color: #fff;
            padding: 8px 14px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 700;
        }

        .soft-divider {
            border: none;
            height: 1px;
            background: linear-gradient(to right, transparent, rgba(255,255,255,0.28), transparent);
            margin: 18px 0 22px;
        }
    </style>
</head>
<body>
<div class="dashboard-shell d-flex">
    <div class="sidebar d-flex flex-column align-items-center">
        <div class="logo-circle">
            <i class="bi bi-cup-hot-fill"></i>
        </div>

        <a href="<%= ctx %>/home?category=Kopi" class="side-icon" title="Trang chủ">
            <i class="bi bi-house-door-fill"></i>
        </a>

        <a href="<%= ctx %>/purchase-history" class="side-icon active" title="Lịch sử mua hàng">
            <i class="bi bi-clock-history"></i>
        </a>

        <div class="mt-auto mb-4">
            <a href="<%= ctx %>/logout" class="side-icon" title="Đăng xuất">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </div>

    <div class="main-content">
        <div class="hero-panel">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <div class="small text-uppercase fw-semibold opacity-75 mb-1">Purchase History</div>
                    <h2 class="hero-title">Lịch sử mua hàng</h2>
                    <p class="mb-0">Xem lại các đơn hàng bạn đã mua tại PolyCoffee.</p>
                </div>

                <div class="profile-chip">
                    Xin chào, <strong><%= user.getFullName() %></strong>
                </div>
            </div>
        </div>

        <hr class="soft-divider">

        <div class="row g-4">
            <div class="col-lg-7">
                <div class="card box p-4 h-100">
                    <h4 class="section-title mb-3">Đơn hàng của bạn</h4>

                    <div class="table-responsive">
                        <table class="table custom-table align-middle">
                            <thead>
                            <tr>
                                <th>Mã HĐ</th>
                                <th>Tổng tiền</th>
                                <th>Trạng thái</th>
                                <th>Ngày tạo</th>
                                <th>Xem</th>
                            </tr>
                            </thead>
                            <tbody>
                            <%
                                if (orders != null && !orders.isEmpty()) {
                                    for (Order o : orders) {
                            %>
                            <tr>
                                <td class="order-code">#<%= o.getId() %></td>
                                <td class="money"><%= String.format("%,.0f", o.getTotalAmount()) %>đ</td>
                                <td>
                                    <% if ("PAID".equalsIgnoreCase(o.getStatus())) { %>
                                        <span class="badge bg-success">Đã thanh toán</span>
                                    <% } else if ("PENDING".equalsIgnoreCase(o.getStatus())) { %>
                                        <span class="badge bg-warning text-dark">Chờ thanh toán</span>
                                    <% } else { %>
                                        <span class="badge bg-secondary"><%= o.getStatus() %></span>
                                    <% } %>
                                </td>
                                <td><%= o.getCreatedAt() %></td>
                                <td>
                                    <a href="<%= ctx %>/purchase-history?orderId=<%= o.getId() %>" class="btn-view">
                                        Chi tiết
                                    </a>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="5" class="text-center text-secondary py-4">Bạn chưa có đơn hàng nào.</td>
                            </tr>
                            <%
                                }
                            %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-lg-5">
                <div class="card box p-4 h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4 class="section-title mb-0">Chi tiết đơn hàng</h4>
                        <% if (selectedOrderId != null) { %>
                            <span class="detail-badge">#<%= selectedOrderId %></span>
                        <% } %>
                    </div>

                    <%
                        if (details == null || details.isEmpty()) {
                    %>
                    <div class="detail-empty">
                        <div>
                            <div class="fw-bold mb-2">Chưa có chi tiết đơn hàng</div>
                            <div>Chọn một đơn hàng ở bên trái để xem thông tin chi tiết.</div>
                        </div>
                    </div>
                    <%
                        } else {
                    %>
                    <div class="table-responsive">
                        <table class="table custom-table align-middle">
                            <thead>
                            <tr>
                                <th>Món</th>
                                <th>Size</th>
                                <th>SL</th>
                                <th>Giá</th>
                                <th>Thành tiền</th>
                            </tr>
                            </thead>
                            <tbody>
                            <%
                                for (OrderDetail d : details) {
                            %>
                            <tr>
                                <td><%= d.getProductName() %></td>
                                <td><%= d.getSize() %></td>
                                <td><%= d.getQuantity() %></td>
                                <td class="money"><%= String.format("%,.0f", d.getPrice()) %>đ</td>
                                <td class="money"><%= String.format("%,.0f", d.getLineTotal()) %>đ</td>
                            </tr>
                            <%
                                }
                            %>
                            </tbody>
                        </table>
                    </div>

                    <div class="mt-3 text-end">
                        <a href="<%= ctx %>/bill?orderId=<%= selectedOrderId %>" class="btn-view">
                            In bill
                        </a>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>