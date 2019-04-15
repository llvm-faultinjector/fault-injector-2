
; <label>:18:                                     ; preds = %14
   %19 = load i32, i32* %6, align 4, !tbaa !2
   %20 = add nsw i32 %19, 1
   store i32 %20, i32* %6, align 4, !tbaa !2
   br label %10

; <label>:18:                                     ; preds = %14
  %19 = load i32, i32* %6, align 4, !tbaa !2
  %20 = call i32 @__faultinject_selected_target(i32 %19)
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %6, align 4, !tbaa !2
  br label %10

; <label>:22:                                     ; preds = %10
  %23 = load i32, i32* %7, align 4, !tbaa !2
  %24 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i32 0, i32 0), i32 %23)
  %25 = bitcast i32* %7 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %25) #3
  %26 = bitcast i32* %6 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %26) #3
  %27 = load i32, i32* %3, align 4
  ret i32 %27
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

declare dso_local void @__marking_faultinject_ptr(i32*) #2

declare dso_local i32 @printf(i8*, ...) #2

  call void @llvm.lifetime.start.p0i8(i64 4, i8* %8) #3
  
   store i32 0, i32* %6, align 4, !tbaa !2
   %9 = bitcast i32* %7 to i8*
   call void @llvm.lifetime.start.p0i8(i64 4, i8* %9) #3
   store i32 0, i32* %7, align 4, !tbaa !2
   call void @__marking_faultinject_ptr(i32* %6)
   store i32 0, i32* %6, align 4, !tbaa !2
   br label %10

.lr.ph:                                           ; preds = %2, %.lr.ph
   %.012 = phi i32 [ %4, %.lr.ph ], [ 0, %2 ]
   %.01011 = phi i32 [ %6, %.lr.ph ], [ 0, %2 ]
   %4 = add nsw i32 %.012, %.01011
   %5 = tail call i32 @__faultinject_selected_target(i32 %.01011) #2
   %6 = add nsw i32 %5, 1
   %7 = icmp slt i32 %6, %0
   br i1 %7, label %.lr.ph, label %._crit_edge


-----------


   %xor_marker = alloca i32
   store i32 524288, i32* %xor_marker
   %3 = icmp sgt i32 %0, 0
   br i1 %3, label %.lr.ph, label %._crit_edge

 .lr.ph:                                           ; preds = %.lr.ph, %2
   %.012 = phi i32 [ %4, %.lr.ph ], [ 0, %2 ]
   %.01011 = phi i32 [ %5, %.lr.ph ], [ 0, %2 ]
   %4 = add nsw i32 %.012, %.01011
   %xor_val = load i32, i32* %xor_marker
   %rfi = xor i32 %.01011, %xor_val
   store i32 0, i32* %xor_marker
   %5 = add nsw i32 %rfi, 1
   %6 = icmp slt i32 %5, %0
   br i1 %6, label %.lr.ph, label %._crit_edge

