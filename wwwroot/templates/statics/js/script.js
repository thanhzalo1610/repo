// ===== SMOOTH SCROLLING =====
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// ===== NAVBAR SCROLL EFFECT =====
let lastScroll = 0;
const header = document.querySelector('.header-main');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;
    
    if (currentScroll > 100) {
        header.style.boxShadow = '0 8px 30px rgba(212, 175, 55, 0.5)';
    } else {
        header.style.boxShadow = '0 4px 20px rgba(212, 175, 55, 0.3)';
    }
    
    lastScroll = currentScroll;
});

// ===== FORM VALIDATION =====
const searchForm = document.getElementById('lawyerSearchForm');

function showAlert(message, type) {
    // Remove existing alerts
    const existingAlert = document.querySelector('.custom-alert');
    if (existingAlert) {
        existingAlert.remove();
    }
    
    // Create alert
    const alert = document.createElement('div');
    alert.className = `custom-alert alert-${type}`;
    alert.innerHTML = `
        <div class="alert-content">
            <span class="alert-icon">${type === 'success' ? '✓' : '⚠'}</span>
            <span class="alert-message">${message}</span>
            <button class="alert-close" onclick="this.parentElement.parentElement.remove()">×</button>
        </div>
    `;
    
    // Add styles
    alert.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        z-index: 9999;
        background: ${type === 'success' ? 'linear-gradient(135deg, #d4af37 0%, #f4d03f 100%)' : 'linear-gradient(135deg, #ff6b6b 0%, #ff8e53 100%)'};
        color: #000;
        padding: 20px 25px;
        border-radius: 10px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        animation: slideInRight 0.5s ease;
        max-width: 400px;
    `;
    
    document.body.appendChild(alert);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        if (alert.parentElement) {
            alert.style.animation = 'slideOutRight 0.5s ease';
            setTimeout(() => alert.remove(), 500);
        }
    }, 5000);
}

// Add animation styles
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(400px);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(400px);
            opacity: 0;
        }
    }
    
    .alert-content {
        display: flex;
        align-items: center;
        gap: 15px;
    }
    
    .alert-icon {
        font-size: 1.5rem;
        font-weight: bold;
    }
    
    .alert-message {
        flex: 1;
        font-weight: 600;
    }
    
    .alert-close {
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: #000;
        font-weight: bold;
        padding: 0;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        transition: all 0.3s ease;
    }
    
    .alert-close:hover {
        background: rgba(0, 0, 0, 0.1);
    }
`;
document.head.appendChild(style);

// ===== CAROUSEL AUTO PLAY =====
const carousel = document.querySelector('#partnersCarousel');
if (carousel) {
    const bsCarousel = new bootstrap.Carousel(carousel, {
        interval: 3000,
        wrap: true
    });
}

// ===== MEGA MENU HOVER EFFECT =====
const megaDropdown = document.querySelector('.mega-dropdown');
if (megaDropdown) {
    megaDropdown.addEventListener('mouseenter', function() {
        this.querySelector('.dropdown-toggle').click();
    });
}

// ===== SCROLL ANIMATIONS =====
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe elements
document.querySelectorAll('.category-card, .feature-item').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'all 0.6s ease';
    observer.observe(el);
});

// ===== ACTIVE NAV LINK ON SCROLL =====
const sections = document.querySelectorAll('section[id]');
const navLinks = document.querySelectorAll('.nav-link');

window.addEventListener('scroll', () => {
    let current = '';
    
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (pageYOffset >= sectionTop - 200) {
            current = section.getAttribute('id');
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${current}`) {
            link.classList.add('active');
        }
    });
});

// ===== MOBILE MENU CLOSE ON CLICK =====
const navbarCollapse = document.querySelector('.navbar-collapse');
const navbarLinks = document.querySelectorAll('.nav-link');

navbarLinks.forEach(link => {
    link.addEventListener('click', () => {
        if (window.innerWidth < 992) {
            const bsCollapse = bootstrap.Collapse.getInstance(navbarCollapse);
            if (bsCollapse) {
                bsCollapse.hide();
            }
        }
    });
});

// ===== FORM INPUT EFFECTS =====
const formInputs = document.querySelectorAll('.form-control, .form-select');

formInputs.forEach(input => {
    input.addEventListener('focus', function() {
        this.parentElement.style.transform = 'scale(1.02)';
        this.parentElement.style.transition = 'transform 0.3s ease';
    });
    
    input.addEventListener('blur', function() {
        this.parentElement.style.transform = 'scale(1)';
    });
});

// ===== LOADING ANIMATION =====
window.addEventListener('load', () => {
    document.body.style.opacity = '0';
    setTimeout(() => {
        document.body.style.transition = 'opacity 0.5s ease';
        document.body.style.opacity = '1';
    }, 100);
});
const modal_show = document.getElementById('exampleModal');
if (modal_show!=null) {
document.addEventListener("DOMContentLoaded", function () {
    modal_show.style.display = "block";
    modal_show.style.opacity = 1;
});

window.onclick = function (event) {
    if (event.target === modal_show) {
        
        modal_show.style.display = "none";
        modal_show.style.opacity = 0;
    }
}
}
document.addEventListener('DOMContentLoaded', function () {
    const devModal = new bootstrap.Modal(document.getElementById('developmentModal'));

    // Show modal after 1 second delay
    setTimeout(() => {
        devModal.show();
    }, 1000);
});