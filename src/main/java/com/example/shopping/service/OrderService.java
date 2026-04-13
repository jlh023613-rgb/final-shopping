package com.example.shopping.service;

import com.example.shopping.entity.*;
import com.example.shopping.mapper.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class OrderService {

    private final OrderMapper orderMapper;
    private final RefundMapper refundMapper;
    private final ComplaintMapper complaintMapper;

    public OrderService(OrderMapper orderMapper, RefundMapper refundMapper, ComplaintMapper complaintMapper) {
        this.orderMapper = orderMapper;
        this.refundMapper = refundMapper;
        this.complaintMapper = complaintMapper;
    }

    public Order findById(Long id) {
        Order order = orderMapper.findById(id);
        if (order != null) {
            checkAndUpdateOrderStatus(order);
            setOrderFlags(order);
        }
        return order;
    }

    public List<Order> findByUserId(Long userId) {
        List<Order> orders = orderMapper.findByUserId(userId);
        for (Order order : orders) {
            checkAndUpdateOrderStatus(order);
            setOrderFlags(order);
        }
        return orders;
    }

    public List<Order> findByMerchantId(Long merchantId) {
        List<Order> orders = orderMapper.findByMerchantId(merchantId);
        for (Order order : orders) {
            checkAndUpdateOrderStatus(order);
        }
        return orders;
    }

    private void checkAndUpdateOrderStatus(Order order) {
        try {
            LocalDateTime now = LocalDateTime.now();

            if ("pending".equals(order.getStatus()) && order.getCreatedAt() != null) {
                long hours = ChronoUnit.HOURS.between(order.getCreatedAt(), now);
                if (hours >= 24) {
                    order.setStatus("cancelled");
                    orderMapper.updateStatus(order);
                }
            }

            if ("delivered".equals(order.getStatus()) && order.getDeliveredAt() != null) {
                long days = ChronoUnit.DAYS.between(order.getDeliveredAt(), now);
                if (days >= 7) {
                    order.setStatus("completed");
                    order.setCompletedAt(now);
                    orderMapper.update(order);
                }
            }
        } catch (Exception e) {
            // ignore update errors
        }
    }

    private void setOrderFlags(Order order) {
        order.setCanComplaint(false);
        order.setCanRefund(false);
        order.setHasComplaint(false);
        order.setHasRefund(false);

        try {
            if ("completed".equals(order.getStatus())) {
                Complaint complaint = complaintMapper.findByOrderId(order.getId());
                order.setHasComplaint(complaint != null);
                order.setCanComplaint(complaint == null);

                Refund refund = refundMapper.findByOrderId(order.getId());
                order.setHasRefund(refund != null);

                if (refund == null && order.getCompletedAt() != null) {
                    long days = ChronoUnit.DAYS.between(order.getCompletedAt(), LocalDateTime.now());
                    order.setCanRefund(days <= 7);
                }
            }
        } catch (Exception e) {
            // ignore flag errors
        }
    }

    @Transactional
    public void acceptOrder(Long orderId, Long merchantId) {
        Order order = orderMapper.findById(orderId);
        if (order != null && order.getMerchantId().equals(merchantId) && "pending".equals(order.getStatus())) {
            order.setStatus("shipping");
            order.setAcceptedAt(LocalDateTime.now());
            orderMapper.update(order);
        }
    }

    @Transactional
    public void deliverOrder(Long orderId, Long merchantId) {
        Order order = orderMapper.findById(orderId);
        if (order != null && order.getMerchantId().equals(merchantId) && "shipping".equals(order.getStatus())) {
            order.setStatus("delivered");
            order.setDeliveredAt(LocalDateTime.now());
            orderMapper.update(order);
        }
    }

    @Transactional
    public void confirmReceive(Long orderId, Long userId) {
        Order order = orderMapper.findById(orderId);
        if (order != null && order.getUserId().equals(userId) && "delivered".equals(order.getStatus())) {
            order.setStatus("completed");
            order.setCompletedAt(LocalDateTime.now());
            orderMapper.update(order);
        }
    }

    @Transactional
    public void cancelOrder(Long orderId, Long userId) {
        Order order = orderMapper.findById(orderId);
        if (order != null && order.getUserId().equals(userId) && "pending".equals(order.getStatus())) {
            order.setStatus("cancelled");
            orderMapper.updateStatus(order);
        }
    }

    @Transactional
    public Refund applyRefund(Long orderId, Long userId, String reason) {
        Order order = orderMapper.findById(orderId);
        if (order == null || !order.getUserId().equals(userId) || !"completed".equals(order.getStatus())) {
            return null;
        }

        Refund existingRefund = refundMapper.findByOrderId(orderId);
        if (existingRefund != null) {
            return null;
        }

        if (order.getCompletedAt() != null) {
            long days = ChronoUnit.DAYS.between(order.getCompletedAt(), LocalDateTime.now());
            if (days > 7) {
                return null;
            }
        }

        Refund refund = new Refund();
        refund.setOrderId(orderId);
        refund.setUserId(userId);
        refund.setMerchantId(order.getMerchantId());
        refund.setReason(reason);
        refund.setStatus("pending");
        refundMapper.insert(refund);
        return refund;
    }

    @Transactional
    public void processRefund(Long refundId, Long merchantId, boolean approved, String result) {
        Refund refund = refundMapper.findById(refundId);
        if (refund == null || !refund.getMerchantId().equals(merchantId) || !"pending".equals(refund.getStatus())) {
            return;
        }

        refund.setStatus(approved ? "approved" : "rejected");
        refund.setResult(result);
        refund.setProcessedAt(LocalDateTime.now());
        refundMapper.update(refund);

        if (approved) {
            Order order = orderMapper.findById(refund.getOrderId());
            if (order != null) {
                order.setStatus("refunded");
                orderMapper.updateStatus(order);
            }
        }
    }

    @Transactional
    public void processRefundByAdmin(Long refundId, boolean approved, String result) {
        Refund refund = refundMapper.findById(refundId);
        if (refund == null || !"pending".equals(refund.getStatus())) {
            return;
        }

        refund.setStatus(approved ? "approved" : "rejected");
        refund.setResult(result);
        refund.setProcessedAt(LocalDateTime.now());
        refundMapper.update(refund);

        if (approved) {
            Order order = orderMapper.findById(refund.getOrderId());
            if (order != null) {
                order.setStatus("refunded");
                orderMapper.updateStatus(order);
            }
        }
    }
}
