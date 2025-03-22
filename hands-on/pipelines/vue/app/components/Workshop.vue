<template>
  <div class="max-w-7xl mx-auto">
    <div class="text-center mb-12">
      <h2 class="text-4xl font-bold mb-4 text-white">DevOps Workshop</h2>
      <p class="text-gray-300">Learn the essentials of DevOps practices and tools</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <!-- Core DevOps Card -->
      <div class="bg-gray-800 rounded-lg shadow-xl p-8">
        <div class="flex items-center justify-center h-12 w-12 rounded-md bg-blue-500 text-white mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
          </svg>
        </div>
        <h3 class="text-xl font-semibold mb-4 text-white">Core DevOps</h3>
        <ul class="text-gray-300 space-y-2">
          <li>• CI/CD Fundamentals</li>
          <li>• Version Control</li>
          <li>• Build Automation</li>
          <li>• Release Management</li>
        </ul>
      </div>

      <!-- Cloud & Infrastructure Card -->
      <div class="bg-gray-800 rounded-lg shadow-xl p-8">
        <div class="flex items-center justify-center h-12 w-12 rounded-md bg-green-500 text-white mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
          </svg>
        </div>
        <h3 class="text-xl font-semibold mb-4 text-white">Cloud & Infrastructure</h3>
        <ul class="text-gray-300 space-y-2">
          <li>• Container Orchestration</li>
          <li>• Infrastructure as Code</li>
          <li>• Cloud Services</li>
          <li>• Scaling Strategies</li>
        </ul>
      </div>

      <!-- Monitoring & Security Card -->
      <div class="bg-gray-800 rounded-lg shadow-xl p-8">
        <div class="flex items-center justify-center h-12 w-12 rounded-md bg-purple-500 text-white mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
          </svg>
        </div>
        <h3 class="text-xl font-semibold mb-4 text-white">Monitoring & Security</h3>
        <ul class="text-gray-300 space-y-2">
          <li>• Log Management</li>
          <li>• Performance Monitoring</li>
          <li>• Security Best Practices</li>
          <li>• Incident Response</li>
        </ul>
      </div>
    </div>

    <form @submit.prevent="handleSubmit" class="space-y-4">
      <div>
        <label for="name" class="block text-sm font-medium text-gray-700">Name</label>
        <input
          id="name"
          v-model="form.name"
          type="text"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
          data-testid="name-input"
        />
        <p v-if="nameError" class="text-red-500 text-sm mt-1">{{ nameError }}</p>
      </div>
      
      <div>
        <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
        <input
          id="email"
          v-model="form.email"
          type="email"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
          data-testid="email-input"
        />
        <p v-if="emailError" class="text-red-500 text-sm mt-1">{{ emailError }}</p>
      </div>
      
      <div>
        <label for="workshop" class="block text-sm font-medium text-gray-700">Workshop</label>
        <select
          id="workshop"
          v-model="form.workshop"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
          data-testid="workshop-select"
        >
          <option value="">Select a workshop</option>
          <option value="docker">Docker Basics</option>
          <option value="kubernetes">Kubernetes for Beginners</option>
          <option value="ci-cd">CI/CD Pipeline Creation</option>
        </select>
      </div>
      
      <button 
        type="submit" 
        class="w-full bg-blue-600 text-white rounded-md py-2"
        data-testid="submit-button"
      >
        Register
      </button>
    </form>

    <TransitionRoot appear :show="showModal" as="template">
      <Dialog as="div" @close="showModal = false" class="relative z-10">
        <TransitionChild enter="ease-out duration-300" enter-from="opacity-0" enter-to="opacity-100" leave="ease-in duration-200" leave-from="opacity-100" leave-to="opacity-0">
          <div class="fixed inset-0 bg-black bg-opacity-25" />
        </TransitionChild>

        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4 text-center">
            <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl bg-gray-800 p-6 text-left align-middle shadow-xl transition-all">
              <DialogTitle class="text-lg font-medium leading-6 text-white">
                Registration Successful!
              </DialogTitle>
              <div class="mt-2">
                <p class="text-sm text-gray-300">
                  Thank you for registering for our DevOps workshop. We'll send you an email with further details.
                </p>
              </div>
              <div class="mt-4">
                <button type="button" @click="showModal = false" class="inline-flex justify-center rounded-md border border-transparent bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2">
                  Close
                </button>
              </div>
            </DialogPanel>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Dialog, DialogPanel, DialogTitle, TransitionRoot, TransitionChild } from '@headlessui/vue'

const form = ref({
  name: '',
  email: '',
  workshop: ''
})

// Basic validation
const nameError = computed(() => {
  if (form.value.name && form.value.name.length < 3) {
    return 'Name must be at least 3 characters'
  }
  return ''
})

const emailError = computed(() => {
  if (form.value.email && !form.value.email.includes('@')) {
    return 'Please enter a valid email address'
  }
  return ''
})

const validateForm = () => {
  return !nameError.value && !emailError.value && form.value.name && form.value.email && form.value.workshop
}

const showModal = ref(false)

const handleSubmit = () => {
  if (validateForm()) {
    // Form submission logic would go here
    console.log('Form submitted:', form.value)
    // Show modal after successful submission
    showModal.value = true
    // Reset form after submission
    form.value = {
      name: '',
      email: '',
      workshop: ''
    }
  }
}
</script>
