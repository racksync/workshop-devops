<script>
	import Modal from '$lib/components/Modal.svelte';
	let name = '';
	let email = '';
	let company = '';
	let phone = '';
	let comments = '';
	let showModal = false;
	let errors = {};

	const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

	function register() {
		// Validate fields
		errors = {};
		if (!name.trim()) {
			errors.name = "Name is required.";
		}
		if (!email.trim()) {
			errors.email = "Email is required.";
		} else if (!emailRegex.test(email)) {
			errors.email = "Invalid email format.";
		}
		 // Validate phone: if provided, must be numeric and not longer than 18 digits.
		if (phone.trim()) {
			if (!/^\d+$/.test(phone)) {
				errors.phone = "Phone number must contain only digits.";
			} else if (phone.trim().length > 18) {
				errors.phone = "Phone number must not exceed 18 digits.";
			}
		}
		// Additional validations can be added here
		
		// If validation issues exist, do not proceed
		if (Object.keys(errors).length > 0) return;
		
		// ...handle registration logic...
		showModal = true;
	}
</script>

<!-- Workshop registration form using plain CSS (no Tailwind) -->
<div class="form-container">
	<h1 class="form-title">Workshop by RACKSYNC CO., LTD.</h1>
	<p class="form-description">
		Join our modern workshop experience. Please fill out the form below to register.
	</p>
	<form on:submit|preventDefault={register}>
		<div class="form-group">
			<label for="name">Name</label>
			<input id="name" type="text" bind:value={name} placeholder="Your full name" />
			{#if errors.name}
				<p class="error-message">{errors.name}</p>
			{/if}
		</div>
		<div class="form-group">
			<label for="email">Email</label>
			<input id="email" type="email" bind:value={email} placeholder="you@example.com" />
			{#if errors.email}
				<p class="error-message">{errors.email}</p>
			{/if}
		</div>
		<div class="form-group">
			<label for="company">Company</label>
			<input id="company" type="text" bind:value={company} placeholder="Your company" />
		</div>
		<div class="form-group">
			<label for="phone">Phone</label>
			<input id="phone" type="tel" bind:value={phone} placeholder="Your phone number" />
			{#if errors.phone}
				<p class="error-message">{errors.phone}</p>
			{/if}
		</div>
		<div class="form-group">
			<label for="comments">Additional Comments</label>
			<textarea id="comments" bind:value={comments} rows="3" placeholder="Any additional information"></textarea>
		</div>
		<button type="submit" class="form-button">Register</button>
	</form>
</div>

<!-- Show modal when registered -->
<Modal show={showModal} message="Your registration has been received. Thank you!" on:close={() => showModal = false} />

<style>
	.form-container {
		max-width: 600px;
		margin: 40px auto;
		padding: 20px;
		background: #fff;
		border: 1px solid #ddd;
		border-radius: 8px;
		box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.1);
	}
	.form-title {
		text-align: center;
		font-size: 24px;
		font-weight: bold;
		margin-bottom: 20px;
	}
	.form-description {
		text-align: center;
		color: #666;
		margin-bottom: 20px;
	}
	.form-group {
		margin-bottom: 15px;
	}
	.form-group label {
		display: block;
		font-size: 14px;
		margin-bottom: 5px;
		color: #333;
	}
	.form-group input,
	.form-group textarea {
		width: 100%;
		padding: 8px;
		border: 1px solid #ccc;
		border-radius: 4px;
		font-size: 14px;
	}
	.error-message {
		color: red;
		font-size: 12px;
		margin-top: 4px;
	}
	.form-button {
		width: 100%;
		padding: 10px;
		background: #007bff;
		border: none;
		border-radius: 4px;
		color: #fff;
		font-size: 16px;
		cursor: pointer;
		transition: background 0.2s ease-in-out;
	}
	.form-button:hover {
		background: #0056b3;
	}
</style>
