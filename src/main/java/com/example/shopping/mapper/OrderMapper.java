package com.example.shopping.mapper;

import com.example.shopping.entity.Order;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface OrderMapper {
    void insert(Order order);
    Order findById(Long id);
    Order findByOrderNo(String orderNo);
    List<Order> findByUserId(Long userId);
    List<Order> findByMerchantId(Long merchantId);
    void updateStatus(Order order);
    void update(Order order);
    List<Order> findPendingOrders();
}
