<template>
  <div class="container">
    <header>
      <img alt="Vue logo" src="./assets/logo.svg" width="125" height="125" />
      <h1>RACKSYNC DevOps Workshop</h1>
    </header>
    
    <main>
      <div class="content">
        <h2>Welcome to Docker & CI/CD Workshop</h2>
        <p>
          This Vue.js application is being served from a Docker container.
          The container was built and deployed through a CI/CD pipeline.
        </p>
      </div>
    </main>

    <footer>
      <p>&copy; 2024 RACKSYNC CO., LTD.</p>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
body {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  margin: 0;
  padding: 0;
  background-color: #f5f5f5;
  color: #2c3e50;
}

.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}

header {
  margin-bottom: 2rem;
}

h1 {
  font-weight: 600;
  color: #42b883;
}

h2 {
  font-weight: 500;
  color: #35495e;
}

.content {
  background-color: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

footer {
  margin-top: 2rem;
  color: #666;
  font-size: 0.9rem;
}
</style>
