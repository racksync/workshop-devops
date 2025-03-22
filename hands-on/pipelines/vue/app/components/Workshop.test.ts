import { mount } from '@vue/test-utils'
import { describe, it, expect, beforeEach, vi } from 'vitest'
import Workshop from './Workshop.vue'

// Mock the Headless UI components that might be causing issues
vi.mock('@headlessui/vue', () => ({
  Dialog: {
    name: 'Dialog',
    template: '<div><slot /></div>',
  },
  DialogPanel: {
    name: 'DialogPanel',
    template: '<div><slot /></div>',
  },
  DialogTitle: {
    name: 'DialogTitle',
    template: '<div><slot /></div>',
  },
  TransitionRoot: {
    name: 'TransitionRoot',
    template: '<div><slot v-if="show"></slot></div>',
    props: ['show']
  },
  TransitionChild: {
    name: 'TransitionChild',
    template: '<div><slot /></div>',
  },
}));

describe('Workshop', () => {
  let wrapper;

  beforeEach(() => {
    // Reset mocks before each test
    vi.resetAllMocks();
    
    // Mount the component with stubs for complex components
    wrapper = mount(Workshop, {
      global: {
        stubs: {
          Dialog: true,
          DialogPanel: true, 
          DialogTitle: true,
          TransitionRoot: true,
          TransitionChild: true
        }
      }
    });
    
    // Mock console.log
    console.log = vi.fn();
  });

  it('renders form fields correctly', () => {
    // Check if all form elements exist
    expect(wrapper.find('[data-testid="name-input"]').exists()).toBe(true);
    expect(wrapper.find('[data-testid="email-input"]').exists()).toBe(true);
    expect(wrapper.find('[data-testid="workshop-select"]').exists()).toBe(true);
    expect(wrapper.find('[data-testid="submit-button"]').exists()).toBe(true);
  });

  it('validates form inputs', async () => {
    // Get form elements
    const nameInput = wrapper.find('[data-testid="name-input"]');
    const emailInput = wrapper.find('[data-testid="email-input"]');
    
    // Test name validation
    await nameInput.setValue('ab');
    await wrapper.vm.$nextTick();
    expect(wrapper.text()).toContain('Name must be at least 3 characters');
    
    // Test email validation
    await emailInput.setValue('invalid-email');
    await wrapper.vm.$nextTick();
    expect(wrapper.text()).toContain('Please enter a valid email address');
    
    // Fix the inputs
    await nameInput.setValue('John Doe');
    await emailInput.setValue('john@example.com');
    await wrapper.vm.$nextTick();
    
    // Ensure error messages are gone
    expect(wrapper.text()).not.toContain('Name must be at least 3 characters');
    expect(wrapper.text()).not.toContain('Please enter a valid email address');
  });

  it('handles form submission correctly', async () => {
    // Fill out the form with valid data
    await wrapper.find('[data-testid="name-input"]').setValue('John Doe');
    await wrapper.find('[data-testid="email-input"]').setValue('john@example.com');
    await wrapper.find('[data-testid="workshop-select"]').setValue('docker');
    
    // Submit the form
    await wrapper.find('form').trigger('submit.prevent');
    
    // Check that console.log was called with the form data
    expect(console.log).toHaveBeenCalled();
    
    // Check that form fields are reset
    expect(wrapper.vm.form.name).toBe('');
    expect(wrapper.vm.form.email).toBe('');
    expect(wrapper.vm.form.workshop).toBe('');
  });
});
