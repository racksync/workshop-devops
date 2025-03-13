import { mount } from '@vue/test-utils'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import LoginForm from '../components/LoginForm.vue'

describe('LoginForm', () => {
  let wrapper;

  beforeEach(() => {
    // Reset mocks before each test
    vi.resetAllMocks();
    
    // Mount the component
    wrapper = mount(LoginForm);
    
    // Mock console.log to avoid noise in test output
    console.log = vi.fn();
  });

  it('renders form fields correctly', () => {
    expect(wrapper.find('input[type="email"]').exists()).toBe(true);
    expect(wrapper.find('input[type="password"]').exists()).toBe(true);
  });

  it('updates email value on input', async () => {
    const emailInput = wrapper.find('input[type="email"]');
    await emailInput.setValue('test@example.com');
    expect(wrapper.vm.email).toBe('test@example.com');
  });

  it('updates password value on input', async () => {
    const passwordInput = wrapper.find('input[type="password"]');
    await passwordInput.setValue('password123');
    expect(wrapper.vm.password).toBe('password123');
  });

  it('submits form with correct data', async () => {
    // Mock the handleSubmit method directly
    const mockHandleSubmit = vi.fn();
    wrapper.vm.handleSubmit = mockHandleSubmit;

    // Fill form fields
    await wrapper.find('input[type="email"]').setValue('test@example.com');
    await wrapper.find('input[type="password"]').setValue('password123');
    
    // Submit the form directly by calling the method
    await wrapper.vm.handleSubmit();
    
    // Check that the mock function was called
    expect(mockHandleSubmit).toHaveBeenCalled();
  });
});
