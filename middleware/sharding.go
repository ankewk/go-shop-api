package middleware

import (
	"fmt"
	"hash/fnv"
	"strconv"
	"strings"
	"sync"

	"gorm.io/gorm"
)

// ShardingConfig 分表配置
type ShardingConfig struct {
	TablePrefix string // 表前缀
	ShardCount  int    // 分表数量
	ShardKey    string // 分表键
}

// ShardingMiddleware 分表中间件
type ShardingMiddleware struct {
	config *ShardingConfig
	mu     sync.RWMutex
}

// NewShardingMiddleware 创建新的分表中间件
func NewShardingMiddleware(config *ShardingConfig) *ShardingMiddleware {
	return &ShardingMiddleware{
		config: config,
	}
}

// GetShardTable 根据分表键获取对应的表名
func (s *ShardingMiddleware) GetShardTable(shardValue interface{}) string {
	if s.config == nil {
		return s.config.TablePrefix
	}

	// 计算哈希值
	hash := s.hashValue(fmt.Sprintf("%v", shardValue))
	
	// 计算分表索引
	shardIndex := hash % uint64(s.config.ShardCount)
	
	// 生成表名
	return fmt.Sprintf("%s_%02d", s.config.TablePrefix, shardIndex)
}

// hashValue 计算字符串的哈希值
func (s *ShardingMiddleware) hashValue(value string) uint64 {
	h := fnv.New64a()
	h.Write([]byte(value))
	return h.Sum64()
}

// ApplySharding 应用分表到查询
func (s *ShardingMiddleware) ApplySharding(db *gorm.DB, shardValue interface{}) *gorm.DB {
	tableName := s.GetShardTable(shardValue)
	return db.Table(tableName)
}

// CreateAllShardTables 创建所有分表
func (s *ShardingMiddleware) CreateAllShardTables(db *gorm.DB, model interface{}) error {
	for i := 0; i < s.config.ShardCount; i++ {
		tableName := fmt.Sprintf("%s_%02d", s.config.TablePrefix, i)
		
		// 检查表是否存在
		var exists bool
		err := db.Raw("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = ?)", tableName).Scan(&exists).Error
		if err != nil {
			return fmt.Errorf("failed to check table existence: %w", err)
		}

		if !exists {
			// 创建表
			if err := db.Table(tableName).Migrator().CreateTable(model); err != nil {
				return fmt.Errorf("failed to create table %s: %w", tableName, err)
		}
		}
	}
	return nil
}

// DropAllShardTables 删除所有分表（谨慎使用）
func (s *ShardingMiddleware) DropAllShardTables(db *gorm.DB, model interface{}) error {
	for i := 0; i < s.config.ShardCount; i++ {
		tableName := fmt.Sprintf("%s_%02d", s.config.TablePrefix, i)
		if err := db.Table(tableName).Migrator().DropTable(model); err != nil {
			return fmt.Errorf("failed to drop table %s: %w", tableName, err)
		}
	}
	return nil
}

// GetAllShardTables 获取所有分表名
func (s *ShardingMiddleware) GetAllShardTables() []string {
	tables := make([]string, s.config.ShardCount)
	for i := 0; i < s.config.ShardCount; i++ {
		tables[i] = fmt.Sprintf("%s_%02d", s.config.TablePrefix, i)
	}
	return tables
}

// GetTableUnionQuery 获取联合查询SQL
func (s *ShardingMiddleware) GetTableUnionQuery(baseQuery string) string {
	tables := s.GetAllShardTables()
	
	// 替换表名为联合查询
	unionParts := make([]string, len(tables))
	for i, table := range tables {
		unionParts[i] = strings.Replace(baseQuery, s.config.TablePrefix, table, 1)
	}
	
	return strings.Join(unionParts, " UNION ALL ")
}

// ShardingQuery 分表查询结构
type ShardingQuery struct {
	Query      string
	Args       []interface{}
	TableIndex int
}