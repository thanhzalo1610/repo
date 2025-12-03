#!/bin/bash

# Management script for Legal Integrity Analytics

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_menu() {
    echo ""
    echo "========================================="
    echo "  Legal Integrity Analytics - Manager"
    echo "========================================="
    echo "1. Xem status"
    echo "2. Xem logs (real-time)"
    echo "3. Restart application"
    echo "4. Stop application"
    echo "5. Start application"
    echo "6. Restart Nginx"
    echo "7. Backup database"
    echo "8. Update application (git pull)"
    echo "9. Exit"
    echo "========================================="
    echo -n "Chọn (1-9): "
}

while true; do
    show_menu
    read choice
    
    case $choice in
        1)
            echo -e "${GREEN}Application Status:${NC}"
            sudo systemctl status legalapp --no-pager
            echo ""
            echo -e "${GREEN}Nginx Status:${NC}"
            sudo systemctl status nginx --no-pager
            ;;
        2)
            echo -e "${YELLOW}Đang xem logs (Ctrl+C để thoát)...${NC}"
            sudo journalctl -u legalapp -f
            ;;
        3)
            echo -e "${YELLOW}Restarting application...${NC}"
            sudo systemctl restart legalapp
            echo -e "${GREEN}✓ Done${NC}"
            ;;
        4)
            echo -e "${YELLOW}Stopping application...${NC}"
            sudo systemctl stop legalapp
            echo -e "${GREEN}✓ Done${NC}"
            ;;
        5)
            echo -e "${YELLOW}Starting application...${NC}"
            sudo systemctl start legalapp
            echo -e "${GREEN}✓ Done${NC}"
            ;;
        6)
            echo -e "${YELLOW}Restarting Nginx...${NC}"
            sudo nginx -t && sudo systemctl restart nginx
            echo -e "${GREEN}✓ Done${NC}"
            ;;
        7)
            BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
            echo -e "${YELLOW}Creating backup: ${BACKUP_FILE}${NC}"
            sudo -u postgres pg_dump MobileOasis_V1 > ${BACKUP_FILE}
            echo -e "${GREEN}✓ Backup saved: ${BACKUP_FILE}${NC}"
            ;;
        8)
            echo -e "${YELLOW}Updating application...${NC}"
            git pull origin main
            sudo systemctl restart legalapp
            echo -e "${GREEN}✓ Updated and restarted${NC}"
            ;;
        9)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
