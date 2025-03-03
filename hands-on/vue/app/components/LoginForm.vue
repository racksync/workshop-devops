<template>
  <form @submit.prevent="handleSubmit" class="space-y-4">
    <div>
      <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
      <input
        id="email"
        v-model="email"
        type="email"
        required
        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
      />
    </div>
    <div>
      <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
      <input
        id="password"
        v-model="password"
        type="password"
        required
        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
      />
    </div>
    <button type="submit" class="w-full bg-blue-600 text-white rounded-md py-2">
      Login
    </button>
  </form>
</template>

<script>
// Using the Options API for better testability with spies
import { defineComponent } from 'vue';

export default defineComponent({
  name: 'LoginForm',
  data() {
    return {
      email: '',
      password: ''
    };
  },
  methods: {
    handleSubmit() {
      // Form submission logic here
      console.log('Form submitted with:', { email: this.email, password: this.password });
      
      // You could emit an event here for parent components to handle
      this.$emit('login', {
        email: this.email,
        password: this.password
      });
      
      // Clear form data after submission
      this.email = '';
      this.password = '';
    }
  }
});
</script>
