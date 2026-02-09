import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatIconModule } from '@angular/material/icon';
import { AuthService } from '../../shared/services/auth.service';
import { NotificationService } from '../../shared/services/notification.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    MatIconModule
  ],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private notificationService = inject(NotificationService);

  loginForm: FormGroup;
  isLoading = false;
  hidePassword = true;
  returnUrl: string;

  constructor() {
    // Redirect if already logged in
    if (this.authService.isAuthenticated()) {
      this.router.navigate(['/ml-assets']);
    }

    // Get return url from route parameters or default to '/'
    this.returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/ml-assets';

    this.loginForm = this.fb.group({
      username: ['', [Validators.required]],
      password: ['', [Validators.required]]
    });
  }

  /**
   * Handle form submission
   */
  onSubmit(): void {
    console.log('[LoginComponent] =================================');
    console.log('[LoginComponent] Form submission started');
    console.log('[LoginComponent] Form valid:', this.loginForm.valid);
    console.log('[LoginComponent] Form values:', this.loginForm.value);
    
    if (this.loginForm.invalid) {
      console.error('[LoginComponent] Form is invalid, aborting');
      return;
    }

    this.isLoading = true;
    const username = this.loginForm.value.username || '';
    const password = this.loginForm.value.password || '';
    
    console.log('[LoginComponent] Extracted username:', username);
    console.log('[LoginComponent] Extracted password length:', password?.length);
    console.log('[LoginComponent] Calling authService.login()...');

    this.authService.login(username, password).subscribe({
      next: (response) => {
        console.log('[LoginComponent] ✅ Login successful!');
        console.log('[LoginComponent] Response:', response);
        this.isLoading = false;
        
        if (response && response.success && response.user) {
          this.notificationService.showSuccess(
            `Welcome ${response.user.displayName}! (${response.user.connectorId})`
          );
          console.log('[LoginComponent] Navigating to:', this.returnUrl);
          this.router.navigate([this.returnUrl]);
        } else {
          console.error('[LoginComponent] Invalid response format');
          this.notificationService.showError('Invalid response from server');
        }
      },
      error: (error) => {
        console.error('[LoginComponent] =================================');
        console.error('[LoginComponent] ❌ Login error caught');
        console.error('[LoginComponent] Error object:', error);
        console.error('[LoginComponent] Error.error:', error?.error);
        console.error('[LoginComponent] Error.error.message:', error?.error?.message);
        console.error('[LoginComponent] Error status:', error?.status);
        console.error('[LoginComponent] =================================');
        
        this.isLoading = false;
        const errorMessage = error?.error?.message || error?.message || 'Invalid username or password';
        console.error('[LoginComponent] Showing error message:', errorMessage);
        this.notificationService.showError(errorMessage);
      },
      complete: () => {
        console.log('[LoginComponent] Subscribe completed');
      }
    });
    console.log('[LoginComponent] Subscribe initiated');
    console.log('[LoginComponent] =================================');
  }

  /**
   * Quick login helpers for development
   */
  loginAsOEG(): void {
    this.loginForm.patchValue({
      username: 'user-conn-user1-demo',
      password: 'user1123'
    });
    this.onSubmit();
  }

  loginAsEdmundo(): void {
    this.loginForm.patchValue({
      username: 'user-conn-user2-demo',
      password: 'user2123'
    });
    this.onSubmit();
  }
}
