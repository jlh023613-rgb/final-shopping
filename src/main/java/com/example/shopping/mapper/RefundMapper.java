package com.example.shopping.mapper;

import com.example.shopping.entity.Refund;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface RefundMapper {
    void insert(Refund refund);
    Refund findById(Long id);
    Refund findByOrderId(Long orderId);
    List<Refund> findByUserId(Long userId);
    List<Refund> findByMerchantId(Long merchantId);
    List<Refund> findAllPending();
    List<Refund> findAll();
    void update(Refund refund);
}
