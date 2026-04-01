<%@ page import="model.User" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();

    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }
    if (!"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(ctx + "/access-denied.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Dashboard - PolyCoffee</title>

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

        .logo-circle:hover {
            transform: translateY(-2px) scale(1.03);
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
            color: #fff;
            width: 100%;
            animation: pageEnterSmooth 0.45s ease;
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
            font-weight: 500;
        }

        .soft-divider {
            border: none;
            height: 1px;
            background: linear-gradient(to right, transparent, rgba(255,255,255,0.28), transparent);
            margin: 18px 0 24px;
        }

        .stat-card {
            border-radius: var(--radius-lg);
            border: 1px solid rgba(138, 90, 82, 0.08);
            background: linear-gradient(180deg, #f8f5f2 0%, #f2ece8 100%);
            color: var(--text-dark);
            box-shadow: var(--shadow-soft);
            transition: all 0.28s ease;
            min-height: 220px;
            overflow: hidden;
            position: relative;
        }

        .stat-card::before {
            content: "";
            position: absolute;
            inset: 0 0 auto 0;
            height: 6px;
            background: linear-gradient(to right, #d58d7d, #8a5a52);
        }

        .stat-card:hover {
            transform: translateY(-6px);
            box-shadow: var(--shadow-hover);
        }

        .stat-icon-wrap {
            width: 62px;
            height: 62px;
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #f0dfd8, #e7d4cc);
            color: var(--coffee-dark);
            font-size: 28px;
            box-shadow: 0 10px 18px rgba(138, 90, 82, 0.12);
            margin-bottom: 16px;
        }

        .stat-label {
            color: var(--text-soft);
            font-weight: 600;
            margin-bottom: 4px;
        }

        .stat-value {
            font-size: 28px;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 10px;
        }

        .stat-desc {
            color: var(--text-soft);
            font-size: 14px;
            min-height: 42px;
        }

        .coffee-btn {
            background: linear-gradient(135deg, var(--coffee), var(--coffee-dark));
            color: white;
            border-radius: 14px;
            border: none;
            font-weight: 700;
            padding: 11px 18px;
            box-shadow: 0 12px 24px rgba(138, 90, 82, 0.18);
            transition: all 0.25s ease;
        }

        .coffee-btn:hover {
            background: linear-gradient(135deg, var(--coffee-dark), #5b3732);
            color: white;
            transform: translateY(-1px);
        }

        .light-pill-btn {
            border-radius: 999px;
            padding: 11px 20px;
            font-weight: 700;
            border: none;
            box-shadow: 0 10px 22px rgba(255,255,255,0.12);
        }

        .quick-panel {
            margin-top: 28px;
            border-radius: var(--radius-lg);
            background: linear-gradient(180deg, #f8f5f2 0%, #f2ece8 100%);
            color: var(--text-dark);
            border: 1px solid rgba(138, 90, 82, 0.08);
            box-shadow: var(--shadow-soft);
            padding: 22px;
        }

        .quick-title {
            font-weight: 800;
            margin-bottom: 14px;
        }

        .quick-link {
            display: flex;
            align-items: center;
            justify-content: space-between;
            text-decoration: none;
            color: var(--text-dark);
            background: #fff;
            border: 1px solid #eee2da;
            border-radius: 16px;
            padding: 16px 18px;
            transition: all 0.22s ease;
            box-shadow: 0 8px 18px rgba(60, 40, 30, 0.06);
        }

        .quick-link:hover {
            transform: translateY(-3px);
            color: var(--coffee-dark);
            box-shadow: 0 14px 28px rgba(60, 40, 30, 0.10);
        }

        .quick-link-left {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .quick-link-icon {
            width: 46px;
            height: 46px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #f0dfd8, #e7d4cc);
            color: var(--coffee-dark);
            font-size: 20px;
        }

        @keyframes pageEnterSmooth {
            from {
                opacity: 0;
                transform: translateY(18px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 991.98px) {
            .sidebar {
                width: 84px;
            }

            .main-content {
                padding: 22px 18px 26px;
            }

            .hero-title {
                font-size: 24px;
            }
        }

        @media (max-width: 767.98px) {
            .dashboard-shell {
                margin: 0;
                min-height: 100vh;
                border-radius: 0;
            }

            .sidebar {
                width: 74px;
                min-height: 100vh;
            }

            .logo-circle {
                width: 52px;
                height: 52px;
                font-size: 22px;
            }

            .side-icon {
                width: 44px;
                height: 44px;
                font-size: 20px;
                margin: 12px auto;
            }

            .hero-panel {
                padding: 18px;
            }

            .stat-value {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
<div class="dashboard-shell d-flex">
    <div class="sidebar d-flex flex-column align-items-center">
        <div class="logo-circle">
            <i class="bi bi-cup-hot-fill"></i>
        </div>

        <a href="<%= ctx %>/admin.jsp" class="side-icon active" title="Dashboard">
            <i class="bi bi-speedometer2"></i>
        </a>

        <a href="<%= ctx %>/admin/users" class="side-icon" title="Quản lý tài khoản">
            <i class="bi bi-people"></i>
        </a>

        <a href="<%= ctx %>/home?category=Kopi" class="side-icon" title="Trang bán hàng">
            <i class="bi bi-cup-straw"></i>
        </a>

        <div class="mt-auto mb-4">
            <a href="<%= ctx %>/logout" class="side-icon" title="Đăng xuất">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </div>

    <div class="flex-grow-1 main-content">
        <div class="hero-panel">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <div class="small text-uppercase fw-semibold opacity-75 mb-1">Admin Dashboard</div>
                    <h2 class="hero-title">Xin chào, <%= user.getFullName() %></h2>
                    <p class="hero-subtitle">Quản lý hệ thống PolyCoffee với giao diện trực quan và hiện đại hơn.</p>
                </div>

                <a href="<%= ctx %>/admin/users" class="btn btn-light light-pill-btn">
                    Quản lý tài khoản
                </a>
            </div>
        </div>

        <hr class="soft-divider">

        <div class="row g-4">
            <div class="col-md-6">
                <div class="card stat-card p-4 h-100">
                    <div class="stat-icon-wrap">
                        <i class="bi bi-person-gear"></i>
                    </div>

                    <div class="stat-label">Phân quyền</div>
                    <div class="stat-value">Admin / User</div>
                    <div class="stat-desc">
                        Quản lý tài khoản, chỉnh sửa thông tin và phân quyền người dùng trong hệ thống.
                    </div>

                    <div class="mt-3">
                        <a href="<%= ctx %>/admin/users" class="btn coffee-btn">
                            Quản lý role
                        </a>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card stat-card p-4 h-100">
                    <div class="stat-icon-wrap">
                        <i class="bi bi-cup-hot"></i>
                    </div>

                    <div class="stat-label">Hệ thống</div>
                    <div class="stat-value">PolyCoffee</div>
                    <div class="stat-desc">
                        Quay về khu vực bán hàng để tiếp tục thao tác với menu, giỏ hàng và đơn thanh toán.
                    </div>

                    <div class="mt-3">
                        <a href="<%= ctx %>/home.jsp" class="btn coffee-btn">
                            Về trang chủ
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="quick-panel">
            <h4 class="quick-title">Truy cập nhanh</h4>

            <div class="row g-3">
                <div class="col-md-6">
                    <a href="<%= ctx %>/admin/users" class="quick-link">
                        <div class="quick-link-left">
                            <div class="quick-link-icon">
                                <i class="bi bi-people-fill"></i>
                            </div>
                            <div>
                                <div class="fw-bold">Tài khoản người dùng</div>
                                <div class="small text-secondary">Xem và cập nhật danh sách tài khoản</div>
                            </div>
                        </div>
                        <i class="bi bi-arrow-right"></i>
                    </a>
                </div>

                <div class="col-md-6">
                    <a href="<%= ctx %>/home.jsp" class="quick-link">
                        <div class="quick-link-left">
                            <div class="quick-link-icon">
                                <i class="bi bi-shop"></i>
                            </div>
                            <div>
                                <div class="fw-bold">Trang bán hàng</div>
                                <div class="small text-secondary">Đi tới giao diện sử dụng chính</div>
                            </div>
                        </div>
                        <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>