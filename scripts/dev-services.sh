#!/bin/bash
set -e

echo "🐳 Legal AI Toolkit - Backing Services"
echo "======================================"

# Function to start services
start_services() {
    echo "🚀 Starting all backing services..."
    docker-compose -f docker-compose.dev.yml up -d postgres redis ipfs vector-db minio
    
    echo "⏳ Waiting for services to initialize..."
    sleep 10
    
    echo "🔍 Checking service health..."
    
    # Check PostgreSQL
    if nc -z localhost 5432; then
        echo "✅ PostgreSQL ready on port 5432"
    else
        echo "❌ PostgreSQL not responding"
    fi
    
    # Check Redis
    if nc -z localhost 6379; then
        echo "✅ Redis ready on port 6379"
    else
        echo "❌ Redis not responding"
    fi
    
    # Check IPFS
    if nc -z localhost 5001; then
        echo "✅ IPFS API ready on port 5001"
    else
        echo "❌ IPFS not responding"
    fi
    
    # Check Vector DB
    if nc -z localhost 6333; then
        echo "✅ Vector DB ready on port 6333"
    else
        echo "❌ Vector DB not responding"
    fi
    
    echo ""
    echo "🌟 All services started successfully!"
}

# Function to stop services
stop_services() {
    echo "🛑 Stopping all backing services..."
    docker-compose -f docker-compose.dev.yml down
    echo "✅ All services stopped"
}

# Function to show service status
show_status() {
    echo "📊 Service Status:"
    echo "=================="
    docker-compose -f docker-compose.dev.yml ps
    echo ""
    echo "🔗 Service URLs:"
    echo "  • PostgreSQL:   localhost:5432"
    echo "  • Redis:        localhost:6379"
    echo "  • IPFS API:     localhost:5001"
    echo "  • IPFS Gateway: http://localhost:8080"
    echo "  • Vector DB:    http://localhost:6333"
    echo "  • MinIO:        http://localhost:9001"
}

# Function to show logs
show_logs() {
    local service=$1
    if [ -z "$service" ]; then
        echo "📋 All service logs:"
        docker-compose -f docker-compose.dev.yml logs --tail=50 -f
    else
        echo "📋 $service logs:"
        docker-compose -f docker-compose.dev.yml logs --tail=50 -f "$service"
    fi
}

# Function to restart services
restart_services() {
    echo "🔄 Restarting all services..."
    docker-compose -f docker-compose.dev.yml restart postgres redis ipfs vector-db minio
    echo "✅ All services restarted"
}

# Function to cleanup everything
cleanup_all() {
    echo "🧹 Cleaning up all data and containers..."
    docker-compose -f docker-compose.dev.yml down -v --remove-orphans
    echo "✅ Complete cleanup finished"
}

# Parse command line arguments
case "${1:-start}" in
    "start")
        start_services
        show_status
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        restart_services
        show_status
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "$2"
        ;;
    "cleanup")
        cleanup_all
        ;;
    "help"|"-h"|"--help")
        echo "Legal AI Toolkit - Service Management"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  start     Start all backing services (default)"
        echo "  stop      Stop all services"
        echo "  restart   Restart all services"
        echo "  status    Show service status"
        echo "  logs      Show logs for all services"
        echo "  logs [service]  Show logs for specific service"
        echo "  cleanup   Stop and remove all containers and volumes"
        echo "  help      Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0                    # Start all services"
        echo "  $0 status             # Check status"
        echo "  $0 logs postgres      # Show PostgreSQL logs"
        echo "  $0 cleanup            # Complete cleanup"
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
esac