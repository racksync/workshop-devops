// Mock browser APIs that aren't available in JSDOM environment
import { vi } from 'vitest'

// Define ResizeObserver globally
class MockResizeObserver {
  observe() {}
  unobserve() {}
  disconnect() {}
}

global.ResizeObserver = MockResizeObserver;

// Mock other potentially missing browser APIs
if (typeof window.matchMedia !== 'function') {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: vi.fn().mockImplementation(query => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  });
}

// Mock Element.scrollTo
Element.prototype.scrollTo = Element.prototype.scrollTo || function() {};

// Mock window.scrollTo
window.scrollTo = vi.fn();

// Mock IntersectionObserver 
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  observe() {}
  unobserve() {}
  disconnect() {}
};

// Add missing properties to DOMRect for element getBoundingClientRect()
if (window.DOMRect === undefined) {
  window.DOMRect = class DOMRect {
    constructor(x, y, width, height) {
      this.x = x || 0;
      this.y = y || 0;
      this.width = width || 0;
      this.height = height || 0;
      this.top = this.y;
      this.bottom = this.y + this.height;
      this.left = this.x;
      this.right = this.x + this.width;
    }

    toJSON() {
      return {
        x: this.x,
        y: this.y,
        width: this.width,
        height: this.height,
        top: this.top,
        bottom: this.bottom,
        left: this.left,
        right: this.right,
      };
    }
  };
}

// Standard mock for animation timing
global.requestAnimationFrame = (callback) => setTimeout(callback, 0);
global.cancelAnimationFrame = (id) => clearTimeout(id);
