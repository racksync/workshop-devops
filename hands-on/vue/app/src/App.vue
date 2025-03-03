<template>
  <div class="app">
    <header>
      <div class="container">
        <h1>RACKSYNC CO., LTD.</h1>
        <nav>
          <ul>
            <li><a href="#about">About</a></li>
            <li><a href="#workshop">Workshop</a></li>
            <li><a href="#contact">Contact</a></li>
          </ul>
        </nav>
      </div>
    </header>

    <main>
      <section id="hero" class="container">
        <h2>DevOps Workshop</h2>
        <p>Learn modern DevOps practices and tools with our comprehensive hands-on workshops</p>
        <a href="https://github.com/racksync/devops-workshop" class="btn" target="_blank">
          View Workshop Materials
        </a>
      </section>

      <section id="about" class="container section">
        <h2>About Us</h2>
        <div class="two-column">
          <div>
            <p>RACKSYNC CO., LTD. is a leading provider of DevOps solutions and training. We help organizations streamline their development and operations processes to deliver software faster and more reliably.</p>
          </div>
          <div>
            <h3>Our Expertise</h3>
            <ul>
              <li>Container Orchestration</li>
              <li>CI/CD Pipeline Implementation</li>
              <li>Infrastructure as Code</li>
              <li>Cloud-Native Architecture</li>
            </ul>
          </div>
        </div>
      </section>

      <section id="workshop" class="container section">
        <h2>Workshop Details</h2>
        <div class="two-column">
          <div>
            <h3>What You'll Learn</h3>
            <ul>
              <li>Docker containerization</li>
              <li>GitHub Actions workflows</li>
              <li>Deployment automation</li>
              <li>Vue.js application development</li>
            </ul>
          </div>
          <div>
            <h3>Repository</h3>
            <p>All workshop materials are available on GitHub:</p>
            <a href="https://github.com/racksync/devops-workshop" target="_blank" class="repo-link">
              github.com/racksync/devops-workshop
            </a>
          </div>
        </div>
      </section>

      <section id="contact" class="container section">
        <h2>Contact Us</h2>
        <p>Interested in our DevOps workshops? Get in touch with us!</p>
        <div class="contact-info">
          <div>
            <h3>Email</h3>
            <p>devops@racksync.com</p>
          </div>
          <div>
            <h3>Follow Us</h3>
            <div class="social-links">
              <a href="https://github.com/racksync" class="social">GitHub</a>
              <a href="https://www.linkedin.com/in/smilex" class="social">LinkedIn</a>
              <a href="https://x.com/racksync" class="social">X</a>
            </div>
          </div>
        </div>
      </section>
    </main>

    <footer>
      <div class="container">
        <p>&copy; {{ new Date().getFullYear() }} RACKSYNC CO., LTD. All rights reserved.</p>
      </div>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  line-height: 1.6;
  color: #333;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

header {
  background-color: #2c3e50;
  color: white;
  padding: 1rem 0;
  position: sticky;
  top: 0;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  z-index: 100;
}

header .container {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

header h1 {
  font-size: 1.5rem;
  font-weight: bold;
}

nav ul {
  display: flex;
  list-style: none;
}

nav li {
  margin-left: 20px;
}

nav a {
  color: white;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.3s;
}

nav a:hover {
  color: #3498db;
}

#hero {
  background-color: #3498db;
  color: white;
  padding: 80px 20px;
  text-align: center;
}

#hero h2 {
  font-size: 2.5rem;
  margin-bottom: 1rem;
}

#hero p {
  font-size: 1.2rem;
  max-width: 700px;
  margin: 0 auto 2rem;
}

.btn {
  display: inline-block;
  background-color: white;
  color: #3498db;
  padding: 12px 24px;
  border-radius: 4px;
  text-decoration: none;
  font-weight: bold;
  transition: all 0.3s;
}

.btn:hover {
  background-color: #2c3e50;
  color: white;
  transform: translateY(-2px);
}

.section {
  padding: 80px 0;
  border-bottom: 1px solid #eee;
}

.section h2 {
  text-align: center;
  margin-bottom: 40px;
  color: #2c3e50;
}

.two-column {
  display: flex;
  gap: 40px;
}

.two-column > div {
  flex: 1;
}

h3 {
  margin-bottom: 16px;
  color: #3498db;
}

ul {
  margin-left: 20px;
  margin-bottom: 20px;
}

.repo-link {
  display: inline-block;
  color: #3498db;
  text-decoration: none;
  font-weight: 500;
  margin-top: 10px;
  border-bottom: 1px dashed #3498db;
}

.contact-info {
  display: flex;
  justify-content: space-around;
  max-width: 800px;
  margin: 0 auto;
  text-align: center;
}

.social-links {
  display: flex;
  gap: 10px;
  justify-content: center;
}

.social {
  background-color: #2c3e50;
  color: white;
  padding: 8px 16px;
  border-radius: 4px;
  text-decoration: none;
}

footer {
  background-color: #2c3e50;
  color: white;
  text-align: center;
  padding: 20px 0;
  margin-top: 40px;
}

@media (max-width: 768px) {
  .two-column {
    flex-direction: column;
  }
  
  header .container {
    flex-direction: column;
    text-align: center;
  }
  
  nav ul {
    margin-top: 10px;
  }
  
  nav li {
    margin: 0 10px;
  }
}
</style>
