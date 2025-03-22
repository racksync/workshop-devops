// Highlight active navigation item
document.addEventListener('DOMContentLoaded', function() {
    const currentPage = window.location.search.split('=')[1] || 'home';
    const navLinks = document.querySelectorAll('.navbar-nav .nav-link');
    
    navLinks.forEach(link => {
        const href = link.getAttribute('href').split('=')[1];
        if (href === currentPage) {
            link.classList.add('active', 'fw-bold');
        }
    });

    // Enable tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
});
