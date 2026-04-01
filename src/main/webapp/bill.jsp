<%@ page import="java.util.List" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderDetail" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    Order order = (Order) request.getAttribute("order");
    List<OrderDetail> details = (List<OrderDetail>) request.getAttribute("details");

    if (order == null) {
        response.sendRedirect(ctx + "/home");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hóa đơn #<%= order.getId() %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            margin: 0;
            padding: 24px;
        }

        .bill-wrap {
            max-width: 800px;
            margin: 0 auto;
            background: #fff;
            padding: 28px;
            border-radius: 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }

        .title {
            text-align: center;
            margin-bottom: 24px;
        }

        .title h1 {
            margin: 0 0 8px;
        }

        .info {
            margin-bottom: 20px;
            line-height: 1.8;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 18px;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }

        th {
            background: #8a5a52;
            color: white;
        }

        .text-right {
            text-align: right;
        }

        .total {
            margin-top: 20px;
            text-align: right;
            font-size: 20px;
            font-weight: bold;
            color: #8a5a52;
        }

        .actions {
            margin-top: 24px;
            display: flex;
            gap: 12px;
            justify-content: center;
        }

        .btn {
            border: none;
            padding: 12px 20px;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-print {
            background: #8a5a52;
            color: white;
        }

        .btn-back {
            background: #ddd;
            color: #333;
        }

        @media print {
            .actions {
                display: none;
            }

            body {
                background: white;
                padding: 0;
            }

            .bill-wrap {
                box-shadow: none;
                border-radius: 0;
                max-width: 100%;
            }
        }
    </style>
</head>
<body>
<div class="bill-wrap">
    <div class="title">
        <h1>POLYCOFFEE</h1>
        <div>HÓA ĐƠN THANH TOÁN</div>
    </div>

    <div class="info">
        <div><strong>Mã hóa đơn:</strong> #<%= order.getId() %></div>
        <div><strong>Khách hàng:</strong> <%= order.getUserFullName() %></div>
        <div><strong>Ngày tạo:</strong> <%= order.getCreatedAt() %></div>
        <div><strong>Phương thức:</strong> <%= order.getPaymentMethod() %></div>
        <div><strong>Trạng thái:</strong> <%= order.getStatus() %></div>
    </div>

    <table>
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
            if (details != null) {
                for (OrderDetail d : details) {
        %>
        <tr>
            <td><%= d.getProductName() %></td>
            <td><%= d.getSize() %></td>
            <td><%= d.getQuantity() %></td>
            <td><%= String.format("%,.0f", d.getPrice()) %>đ</td>
            <td><%= String.format("%,.0f", d.getLineTotal()) %>đ</td>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>

    <div class="total">
        Tổng cộng: <%= String.format("%,.0f", order.getTotalAmount()) %>đ
    </div>

    <div class="actions">
        <button class="btn btn-print" onclick="window.print()">In hóa đơn</button>
        <a href="<%= ctx %>/home" class="btn btn-back">Về trang chủ</a>
    </div>
</div>
</body>
</html>