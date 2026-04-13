package com.example.shopping.mapper;

import com.example.shopping.entity.Admin;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AdminMapper {
    Admin findByUsername(String username);
}
