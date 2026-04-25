package com.example.shopping.mapper;

import com.example.shopping.entity.Product;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface ProductMapper {
    List<Product> findAll();
    
    List<Product> findRandom(int limit);
    
    List<Product> findByNameContainingIgnoreCase(String keyword);
    
    List<Product> findByCategory(String category);
    
    Product findById(Long id);

    List<Product> findByMerchantId(Long merchantId);
    
    void insert(Product product);
    
    void update(Product product);
    
    void delete(Long id);

    @Select("SELECT * FROM products WHERE status = 1 AND (merchant_id IS NULL OR merchant_id IN (SELECT id FROM shops))")
    List<Product> findActiveAll();

    int decreaseStock(@Param("productId") Long productId, @Param("quantity") Integer quantity);

    List<Product> findByPage(@Param("category") String category, @Param("offset") int offset, @Param("pageSize") int pageSize);

    int countByCategory(@Param("category") String category);

    List<Product> findMerchantApplicationsByStatus(@Param("status") Integer status);

    void updateAuditStatus(@Param("id") Long id,
                           @Param("status") Integer status,
                           @Param("auditReason") String auditReason,
                           @Param("auditedAt") LocalDateTime auditedAt);
}
