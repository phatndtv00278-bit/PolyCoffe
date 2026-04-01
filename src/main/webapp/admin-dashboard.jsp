<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }

    int totalOrders = request.getAttribute("totalOrders") != null ? (Integer) request.getAttribute("totalOrders") : 0;
    double totalRevenue = request.getAttribute("totalRevenue") != null ? (Double) request.getAttribute("totalRevenue") : 0;
    double todayRevenue = request.getAttribute("todayRevenue") != null ? (Double) request.getAttribute("todayRevenue") : 0;
    List<Order> recentOrders = (List<Order>) request.getAttribute("recentOrders");

    String fromDate = request.getAttribute("fromDate") != null ? (String) request.getAttribute("fromDate") : "";
    String toDate = request.getAttribute("toDate") != null ? (String) request.getAttribute("toDate") : "";
    boolean hasFilter = request.getAttribute("hasFilter") != null && (Boolean) request.getAttribute("hasFilter");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Admin - PolyCoffee</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        :root {
            --coffee: #8a5a52;
            --coffee-dark: #6d433d;
            --coffee-soft: #b8867d;
            --text-dark: #2f2a28;
            --text-soft: #7a6d68;
            --shadow-soft: 0 10px 30px rgba(37, 24, 19, 0.10);
            --shadow-hover: 0 18px 38px rgba(37, 24, 19, 0.16);
            --radius-xl: 28px;
            --radius-lg: 22px;
            --radius-md: 16px;
        }

        * {
            box-sizing: border-box;
        }

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
            backdrop-filter: blur(8px);
        }

        .sidebar {
            width: 102px;
            background: rgba(248, 244, 240, 0.92);
            min-height: calc(100vh - 24px);
            border-right: 1px solid rgba(138, 90, 82, 0.08);
            box-shadow: inset -1px 0 0 rgba(255,255,255,0.45);
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
            transition: transform 0.25s ease;
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

        .hero-subtitle {
            color: rgba(255,255,255,0.76);
            margin-bottom: 0;
        }

        .profile-chip {
            background: rgba(255,255,255,0.10);
            border: 1px solid rgba(255,255,255,0.10);
            padding: 10px 14px;
            border-radius: 18px;
            backdrop-filter: blur(6px);
        }

        .filter-card,
        .stat-card,
        .table-card {
            border-radius: var(--radius-lg);
            border: 1px solid rgba(138, 90, 82, 0.08);
            background: linear-gradient(180deg, #f8f5f2 0%, #f2ece8 100%);
            box-shadow: var(--shadow-soft);
            color: var(--text-dark);
        }

        .stat-card {
            overflow: hidden;
            position: relative;
            transition: all 0.28s ease;
            min-height: 170px;
        }

        .stat-card::before {
            content: "";
            position: absolute;
            inset: 0 0 auto 0;
            height: 6px;
            background: linear-gradient(to right, #d58d7d, #8a5a52);
        }

        .stat-icon {
            width: 58px;
            height: 58px;
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            background: linear-gradient(135deg, #f0dfd8, #e7d4cc);
            color: var(--coffee-dark);
            box-shadow: 0 10px 18px rgba(138, 90, 82, 0.12);
        }

        .stat-label {
            color: var(--text-soft);
            font-weight: 600;
            margin-top: 14px;
            margin-bottom: 6px;
        }

        .stat-value {
            font-size: 32px;
            font-weight: 800;
            line-height: 1.15;
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
            font-size: 14px;
            white-space: nowrap;
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

        .filter-input {
            border-radius: 14px;
            border: 1px solid #ddd3cc;
            min-height: 46px;
        }

        .btn-coffee {
            background: linear-gradient(135deg, var(--coffee), var(--coffee-dark));
            color: white;
            border: none;
            border-radius: 14px;
            font-weight: 700;
            min-height: 46px;
        }

        .btn-coffee:hover {
            color: white;
            background: linear-gradient(135deg, var(--coffee-dark), #5b3732);
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

        <a href="<%= ctx %>/home?category=Kopi" class="side-icon" title="Trang bán hàng">
            <i class="bi bi-house-door-fill"></i>
        </a>

        <a href="<%= ctx %>/admin/dashboard" class="side-icon active" title="Thống kê doanh thu">
            <i class="bi bi-bar-chart-line-fill"></i>
        </a>

        <a href="<%= ctx %>/admin/orders" class="side-icon" title="Danh sách hóa đơn">
            <i class="bi bi-wallet2"></i>
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
                    <div class="small text-uppercase fw-semibold opacity-75 mb-1">Admin Dashboard</div>
                    <h2 class="hero-title">Thống kê doanh thu</h2>
                    <p class="hero-subtitle">Theo dõi tình hình bán hàng và các hóa đơn gần đây của PolyCoffee.</p>
                </div>

                <div class="profile-chip">
                    Xin chào, <strong><%= user.getFullName() %></strong>
                </div>
            </div>
        </div>

        <hr class="soft-divider">

        <div class="card filter-card p-4 mb-4">
            <h4 class="section-title mb-3">Lọc theo ngày</h4>
            <form action="<%= ctx %>/admin/dashboard" method="get">
                <div class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label fw-semibold text-dark">Từ ngày</label>
                        <input type="date" name="fromDate" class="form-control filter-input" value="<%= fromDate %>">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold text-dark">Đến ngày</label>
                        <input type="date" name="toDate" class="form-control filter-input" value="<%= toDate %>">
                    </div>
                    <div class="col-md-4 d-flex gap-2">
                        <button type="submit" class="btn btn-coffee flex-grow-1">
                            <i class="bi bi-funnel me-1"></i>Lọc
                        </button>
                        <a href="<%= ctx %>/admin/dashboard" class="btn btn-secondary flex-grow-1 rounded-4">
                            Làm mới
                        </a>
                    </div>
                </div>
            </form>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="card stat-card p-4">
                    <div class="stat-icon">
                        <i class="bi bi-receipt"></i>
                    </div>
                    <div class="stat-label"><%= hasFilter ? "Hóa đơn trong khoảng ngày" : "Tổng hóa đơn" %></div>
                    <div class="stat-value"><%= totalOrders %></div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card stat-card p-4">
                    <div class="stat-icon">
                        <i class="bi bi-sun"></i>
                    </div>
                    <div class="stat-label">Doanh thu hôm nay</div>
                    <div class="stat-value"><%= String.format("%,.0f", todayRevenue) %>đ</div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card stat-card p-4">
                    <div class="stat-icon">
                        <i class="bi bi-cash-stack"></i>
                    </div>
                    <div class="stat-label"><%= hasFilter ? "Doanh thu theo khoảng ngày" : "Tổng doanh thu" %></div>
                    <div class="stat-value"><%= String.format("%,.0f", totalRevenue) %>đ</div>
                </div>
            </div>
        </div>

        <div class="card table-card p-4">
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <h4 class="section-title mb-0">Hóa đơn gần đây</h4>
                <a href="<%= ctx %>/admin/orders" class="btn btn-coffee">Xem tất cả hóa đơn</a>
            </div>

            <div class="table-responsive">
                <table class="table custom-table align-middle">
                    <thead>
                    <tr>
                        <th>Mã HĐ</th>
                        <th>Khách/User</th>
                        <th>Tổng tiền</th>
                        <th>Ngày tạo</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (recentOrders != null && !recentOrders.isEmpty()) {
                            for (Order o : recentOrders) {
                    %>
                    <tr>
                        <td class="order-code">#<%= o.getId() %></td>
                        <td><%= o.getUserFullName() %></td>
                        <td class="money"><%= String.format("%,.0f", o.getTotalAmount()) %>đ</td>
                        <td><%= o.getCreatedAt() %></td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="4" class="text-center text-secondary py-4">Không có dữ liệu trong khoảng ngày đã chọn.</td>
                    </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>