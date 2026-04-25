package com.example.shopping.mapper;

import com.example.shopping.entity.Merchant;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MerchantMapper {
    void insert(Merchant merchant);
    Merchant findById(Long id);
    Merchant findByUsername(String username);
    List<Merchant> findByStatus(String status);
    List<Merchant> findAll();
    void updateStatus(Merchant merchant);
    void updateCategory(Merchant merchant);
    void updateClosure(Merchant merchant);
    void clearClosure(@Param("id") Long id);
    void update(Merchant merchant);
}
