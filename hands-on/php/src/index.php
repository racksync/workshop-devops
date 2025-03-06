<?php
$page = isset($_GET['page']) ? $_GET['page'] : 'home';

// Basic routing
switch ($page) {
    case 'about':
        include 'pages/about.php';
        break;
    case 'services':
        include 'pages/services.php';
        break;
    case 'home':
    default:
        include 'pages/home.php';
        break;
}
?>
